class AssignmentsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_assignment, only: %i[show edit update destroy remove_image]

  def index
    @page_title = t("assignments.index.page_title")
    @active_nav = "assignments"
    scope = current_user.assignments.includes(assignment_images: { image_attachment: :blob }).order(created_at: :desc)
    scope = scope.where("content ILIKE ?", "%#{Assignment.sanitize_sql_like(params[:search])}%") if params[:search].present?
    scope = scope.where(status: params[:status]) if Assignment.statuses.key?(params[:status])
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
    @assignment = current_user.assignments.new
    @page_title = t("assignments.new.page_title")
    @active_nav = "create"
  end

  def edit
    @page_title = t("assignments.edit.page_title")
    @active_nav = "create"
  end

  def create
    @assignment = current_user.assignments.new
    assign_attributes_with_images

    if @assignment.save
      @assignment.sync_status_with_images!

    if @new_images_uploaded
      AssignmentMailer.submitted(@assignment).deliver_later
    end

    redirect_to @assignment, notice: t("flash.assignments.created")
    else
      prepare_form
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_attributes_with_images

    if @assignment.save
      update_image_positions!

      @assignment.sync_status_with_images!

      if @new_images_uploaded
        AssignmentMailer.submitted(@assignment).deliver_later # deliver_later - send email in background, deliver_now - send email immediately
      end

      redirect_to @assignment, notice: t("flash.assignments.updated")
    else
      prepare_form
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: t("flash.assignments.deleted")
  end

  def remove_image
    attachment = @assignment.images.attachments.find(params[:attachment_id])
    attachment.purge
    @assignment.images.reload
    @assignment.sync_status_with_images!
    redirect_to edit_assignment_path(@assignment), notice: t("flash.assignments.image_removed")
  end

  private

  def set_assignment
    id = params[:id] || params[:assignment_id]
    @assignment = current_user.assignments.find(id)
  end

  def assignment_params
    params.require(:assignment).permit(:content, images: [])
  end

  def assign_attributes_with_images
    permitted = assignment_params
    new_images = permitted.delete(:images)

    new_images = new_images&.reject(&:blank?) || []

    @new_images_uploaded = new_images.any?

    @assignment.assign_attributes(permitted)

    return unless @new_images_uploaded

    @assignment.validate_uploaded_images(new_images)

    return if @assignment.errors.any?

    next_position = @assignment.assignment_images.maximum(:position).to_i + 1

    new_images.each do |file|
      assignment_image = @assignment.assignment_images.build(
        position: next_position
      )

      assignment_image.image.attach(file)

      next_position += 1
    end
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

  def prepare_form
    @page_title = @assignment.new_record? ? t("assignments.new.page_title") : t("assignments.edit.page_title")
    @active_nav = "create"
  end
end
