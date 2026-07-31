class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_assignment, only: %i[show edit update destroy remove_image]

  def index
    @page_title = "Assignments"
    @active_nav = "assignments"
    scope = current_user.assignments.with_attached_images.order(created_at: :desc)
    scope = scope.where("content ILIKE ?", "%#{Assignment.sanitize_sql_like(params[:search])}%") if params[:search].present?
    scope = scope.where(status: params[:status]) if Assignment.statuses.key?(params[:status])
    # @pagy, @assignments = pagy(:offset, scope, limit: 3)


    respond_to do |format|
      format.html do
        @pagy, @assignments = pagy(:offset, scope, limit: 4)
      end

      format.xlsx do
      @assignments = scope.to_a
      @export_image_paths = {}
      temporary_files = []

        begin
          @assignments.each do |assignment|
            @export_image_paths[assignment.id] =
              assignment.images.filter_map do |image|
                next unless image.blob.image?

                extension = File.extname(image.filename.to_s)

                tempfile = Tempfile.new(
                  [ "assignment-#{assignment.id}-", extension ]
                )

                tempfile.binmode
                tempfile.write(image.blob.download)
                tempfile.flush

                temporary_files << tempfile

                tempfile.path
              end
          end

        response.headers["Content-Disposition"] =
          %(attachment; filename="assignments_#{Date.current}.xlsx")

        render template: "assignments/index",
               formats: [ :xlsx ],
               handlers: [ :axlsx ],
               layout: false
        ensure
          temporary_files.each(&:close!)
        end
      end
    end
  end

  def show
    @page_title = "Assignment details"
    @active_nav = "assignments"
  end

  def new
    @assignment = current_user.assignments.new
    @page_title = "Create assignment"
    @active_nav = "create"
  end

  def edit
    @page_title = "Edit assignment"
    @active_nav = "create"
  end

  def create
    @assignment = current_user.assignments.new
    assign_attributes_with_images

    if @assignment.save
      @assignment.sync_status_with_images!
      redirect_to @assignment, notice: "Assignment created successfully."
    else
      prepare_form
      render :new, status: :unprocessable_entity
    end
  end

  def update
    assign_attributes_with_images

    if @assignment.save
      @assignment.sync_status_with_images!
      redirect_to @assignment, notice: "Assignment updated successfully."
    else
      prepare_form
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: "Assignment deleted successfully."
  end

  def remove_image
    attachment = @assignment.images.attachments.find(params[:attachment_id])
    attachment.purge
    @assignment.images.reload
    @assignment.sync_status_with_images!
    redirect_to edit_assignment_path(@assignment), notice: "Image removed successfully."
  end

  private

  def set_assignment
    @assignment = current_user.assignments.find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:content, images: [])
  end

  def assign_attributes_with_images
    permitted = assignment_params
    new_images = permitted.delete(:images)
    @assignment.assign_attributes(permitted)
    if new_images.present?
      @assignment.validate_uploaded_images(new_images)
      @assignment.images.attach(new_images) unless @assignment.errors.any?
    end
  end

  def prepare_form
    @page_title = @assignment.new_record? ? "Create assignment" : "Edit assignment"
    @active_nav = "create"
  end
end
