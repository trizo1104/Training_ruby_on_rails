class ApplicationController < ActionController::Base
  include Pagy::Method
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    assignments_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  private

  def render_not_found
    render template: "errors/not_found", layout: "errors", status: :not_found
  end
end
