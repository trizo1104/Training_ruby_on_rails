class AssignmentsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_assignment, only: %i[show edit update destroy remove_image]

  def index
    @page_title = t("assignments.index.page_title")
    @active_nav = "assignments"

    @companies = Company.order(:name) if current_user.has_role?("Admin")

    # scope = current_user.company.assignments.includes(assignment_images: { image_attachment: :blob }).order(created_at: :desc)
    scope = policy_scope(Assignment)
          .includes(:user, assignment_images: { image_attachment: :blob })
          .order(created_at: :desc)
    scope = scope.where("content ILIKE ?", "%#{Assignment.sanitize_sql_like(params[:search])}%") if params[:search].present?
    scope = scope.where(status: params[:status]) if Assignment.statuses.key?(params[:status])

    if current_user.has_role?("Admin")
      scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?
    end
    # @pagy, @assignments = pagy(:offset, scope, limit: 3)

    respond_to do |format|
      format.html do
        @pagy, @assignments = pagy(:offset, scope, limit: 4)
      end

      format.xlsx do
        exporter = Assignments::XlsxExporter.new(scope.to_a)

        @assignments = exporter.assignments
        @export_image_paths = exporter.export_image_paths

        exporter.prepare

        response.headers["Content-Disposition"] =
          %(attachment; filename="assignments_#{Date.current}.xlsx")

        render template: "assignments/index",
              formats: [ :xlsx ],
              handlers: [ :axlsx ],
              layout: false
      ensure
        exporter.cleanup
      end

      format.xml do
        exporter = Assignments::XmlExporter.new(scope.to_a)
        xml = exporter.call

        send_data(
          xml,
          filename: "assignments_#{Date.current}.xml",
          type: "application/xml",
          disposition: "attachment"
        )
      end

      format.pdf do
        @assignments = scope.to_a
        @user = current_user

         render pdf: "assignments",
                layout: "pdf",
                disposition: "inline", # 2 types: inline - view immediately on browser, attachment - download the file
                footer: {
                  html: {
                    template: "shared/pdf_footer"
                  }
                }
      end
    end
  end

  def show
    @page_title = t("assignments.show.page_title")
    @active_nav = "assignments"
  end

  def new
    @assignment = Assignment.new(user: current_user)

    authorize @assignment, :new?

     if current_user.has_role?("Admin")
      @companies = Company.order(:name)
     end

    @page_title = t("assignments.new.page_title")
    @active_nav = "create"
  end

  def edit
    authorize @assignment, :update?

    if current_user.has_role?("Admin")
      @companies = Company.order(:name)
      @managers = @assignment.company.users
                            .joins(:roles)
                            .where(roles: { name: "Manager" })
    end
      @page_title = t("assignments.edit.page_title")
      @active_nav = "create"
  end

  def create
    @assignment = Assignment.new

    assign_assignment_owner

    permitted = assignment_params
    images = permitted.delete(:images)&.reject(&:blank?) || []

    @assignment.assign_attributes(permitted)

    Assignment.transaction do
      @assignment.save!

      attach_images!(images)

      @assignment.sync_status_with_images!
    end

    AssignmentMailer.submitted(@assignment).deliver_later if images.any?  # deliver_later - send email in background, deliver_now - send email immediately

    redirect_to @assignment, notice: t("flash.assignments.created")
  rescue ActiveRecord::RecordInvalid
    prepare_form
    render :new, status: :unprocessable_entity
  end


  def update
    permitted = assignment_params
    images = permitted.delete(:images)&.reject(&:blank?) || []

    @assignment.assign_attributes(permitted)

    Assignment.transaction do
      @assignment.save!

      attach_images!(images)

      update_image_positions!

      @assignment.sync_status_with_images!
    end

    AssignmentMailer.submitted(@assignment).deliver_later if images.any?

    redirect_to @assignment, notice: t("flash.assignments.updated")
  rescue ActiveRecord::RecordInvalid
    prepare_form
    render :edit, status: :unprocessable_entity
  end


  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: t("flash.assignments.deleted")
  end

  def remove_image
    assignment_image = @assignment.assignment_images.find(params[:attachment_id])

    assignment_image.image.purge
    assignment_image.destroy

    @assignment.sync_status_with_images!

    redirect_to edit_assignment_path(@assignment),
                notice: t("flash.assignments.image_removed")
  end

  private

  def attach_images!(images)
    return if images.empty?

    total_images =
      @assignment.assignment_images.count + images.size

    if total_images > Assignment::MAX_IMAGE_COUNT
      @assignment.errors.add(:images, :too_many)
      raise ActiveRecord::RecordInvalid, @assignment
    end

    next_position =
      @assignment.assignment_images.maximum(:position).to_i + 1

    images.each do |file|
      assignment_image = @assignment.assignment_images.build(
        position: next_position
      )

      assignment_image.image.attach(file)

      assignment_image.save!

      next_position += 1
    end
  end


  def set_assignment
    id = params[:id] || params[:assignment_id]
    # @assignment = current_user.company.assignments.find(id)
    @assignment = policy_scope(Assignment).find(id)
  end

  def assignment_params
    params.require(:assignment).permit(
      :content,
      :company_id,
      :user_id,
      images: []
    )
  end

  def update_image_positions!
    ids = params[:image_ids].to_s
              .split(",")
              .map(&:to_i)

    return if ids.empty?

    if ids.uniq.size != ids.size
      raise ActiveRecord::RecordInvalid.new(@assignment)
    end

    assignment_images =
      @assignment.assignment_images.where(id: ids)

    if assignment_images.size != ids.size
      raise ActiveRecord::RecordInvalid.new(@assignment)
    end

    images_by_id = assignment_images.index_by(&:id)

    # Temporary negative positions
    # to avoid unique constraint violation
    AssignmentImage.transaction do
      assignment_images.each_with_index do |assignment_image, index|
        assignment_image.update!(
          position: -(index + 1)
        )
      end

      # Apply the new order
      ids.each_with_index do |id, index|
        images_by_id.fetch(id).update!(
          position: index + 1
        )
      end
    end
  end

  # check if role Admin to assign owner and company
  def assign_assignment_owner
    if current_user.has_role?("Admin")
      company = Company.find(params[:assignment][:company_id])
      manager = company.users
                      .joins(:roles)
                      .where(roles: { name: "Manager" })
                      .find(params[:assignment][:user_id])

      @assignment.company = company
      @assignment.user = manager
    else
      @assignment.company = current_user.company
      @assignment.user = current_user
    end
  end

  def prepare_form
    @page_title = @assignment.new_record? ? t("assignments.new.page_title") : t("assignments.edit.page_title")
    @active_nav = "create"
  end
end
