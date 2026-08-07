module Assignments
  class XlsxExporter
    attr_reader :assignments, :export_image_paths

    def initialize(assignments)
      @assignments = assignments
      @export_image_paths = {}
      @temporary_files = []
    end

    def prepare
      assignments.each do |assignment|
        export_image_paths[assignment.id] = prepare_images(assignment)
      end
    end

    def cleanup
      @temporary_files.each(&:close!)
    end

    private

    attr_reader :temporary_files

    def prepare_images(assignment)
      assignment.images.filter_map do |image|
        next unless image.blob.image?

        create_tempfile(image, assignment.id)
      end
    end

    def create_tempfile(image, assignment_id)
      # extension = File.extname(image.filename.to_s)

      variant = image.variant(format: :png).processed # convert all images to png format for xlsx export

      tempfile = Tempfile.new(
        [ "assignment-#{assignment_id}-", ".png" ]
      )

      tempfile.binmode
      tempfile.write(variant.download)
      tempfile.flush

      temporary_files << tempfile

      tempfile.path
    end
  end
end
