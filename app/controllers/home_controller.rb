class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_request!
  def index
    redirect_to assignments_path(locale: I18n.default_locale)
  end
end
