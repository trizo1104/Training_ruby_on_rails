class ErrorsController < ApplicationController
  layout "errors"

  def not_found
    render status: :not_found
  end
end
