module Assignments
  class XmlExporter
    def initialize(assignments)
      @assignments = assignments
    end

    def call
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            build_root(xml)
        end

        builder.to_xml
    end

    private

    attr_reader :assignments
    # create getter method
    #
    # attr_writer :assignments (only write)
    # attr_accessor :assignments (both write and read)

    def build_root(xml)
        xml.assignments(
            version: "1.0",
            exported_at: Time.current.iso8601
        ) do
            build_assignments(xml)
         end
    end

    def build_assignments(xml)
      assignments.each do |assignment|
        build_assignment(xml, assignment)
      end
    end

    def build_assignment(xml, assignment)
      xml.assignment do
        xml.id assignment.id
        xml.content assignment.content
        xml.status assignment.status
        xml.created_at assignment.created_at&.iso8601
        xml.updated_at assignment.updated_at&.iso8601
        build_images(xml, assignment)
      end
    end

    def build_images(xml, assignment)
       xml.images do
        assignment.images.each do |image|
          build_image(xml, image)
        end
      end
    end

    def build_image(xml, image)
      xml.image do
        xml.filename image.filename.to_s
        xml.content_type image.content_type
        xml.byte_size image.byte_size
        xml.base64 ImageEncoder.new(image).call
      end
    end
  end
end
