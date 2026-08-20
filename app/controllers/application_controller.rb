class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Method

  before_action :authenticate_user!
  before_action :authorize_request!

  around_action :switch_locale

  class_attribute :required_permissions, default: {}

  def default_url_options
    { locale: I18n.locale }
  end

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
  def authorize_request!
    permission = required_permissions[action_name.to_sym]

    return unless permission

    resource, action = permission

    return if current_user.has_permission?(resource, action)

    redirect_to root_path,
                alert: "Bạn không có quyền thực hiện thao tác này."
  end

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale

    I18n.with_locale(locale, &action)
  end

  def render_not_found
    render template: "errors/not_found", layout: "errors", status: :not_found
  end
end
