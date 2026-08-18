class HomeController < ApplicationController
  def index
    redirect_to assignments_path(locale: I18n.default_locale)
  end
end
