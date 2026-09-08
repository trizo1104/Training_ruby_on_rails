class ErrorsController < ApplicationController
  layout "errors"

  def not_found
    render status: :not_found
  end

  def forbidden
    render status: :forbidden
  end
end
