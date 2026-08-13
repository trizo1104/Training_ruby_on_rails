module Assignments
  class ImageEncoder
    def initialize(image)
      @image = image
    end

    def call
      encode_base64(resized_binary)

      # puts tempfile.path # just use when debugging
    end

    def resized_for_email
      resized_binary
    end

    def data_uri
        "data:#{image.content_type};base64,#{call}"
    end

    private

    attr_reader :image

    def resized_binary
      binary = download_image

      tempfile = create_tempfile(binary)

      resized_tempfile = resize_image(tempfile)

      read_binary(resized_tempfile)
    ensure
      tempfile&.close! # close the tempfile and delete it from the filesystem
      resized_tempfile&.close! # close the resized tempfile and delete it from the filesystem
    end

    def download_image
        image.download
    end

    def create_tempfile(binary)
      tempfile = Tempfile.new([ "assignment", ".#{image.filename.extension}" ])
      tempfile.binmode # open the file in binary mode - becausse images are binary files
      tempfile.write(binary)
      tempfile.rewind # move the file pointer back to begin - make sure that the file is ready to be read from the beginning
      tempfile
    end

    def resize_image(tempfile)
      ImageProcessing::Vips
        .source(tempfile) # specify the origin source image
        .resize_to_limit(800, 800) # maximum width and height of 800 pixels
        .call # excute th processing
    end

    def read_binary (resized)
      File.binread(resized.path)
    end

    def encode_base64 (resized_binary)
      Base64.strict_encode64(resized_binary) # encode the binary data to base64
    end
  end
end
