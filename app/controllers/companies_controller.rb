class CompaniesController < ApplicationController
  def index
    @page_title = t("companies.index.page_title")
    @active_nav = "companies"

     @companies = policy_scope(Company)

     @pagy, @companies = pagy(:offset, @companies, limit: 4)
  end
end
