class CompaniesController < ApplicationController
  def index
    @page_title = t("companies.index.page_title")
    @active_nav = "companies"

     @companies = policy_scope(Company)

     @pagy, @companies = pagy(:offset, @companies, limit: 4)
  end

  def new
    @page_title = t("companies.new.page_title")
    @active_nav = "companies"

    @company = Company.new

    authorize @company
  end

  def create
    @company = Company.new(company_params)

    authorize @company

    if @company.save
      redirect_to companies_path(locale: I18n.locale),
                  notice: t("companies.create.success")
    else
      @page_title = t("companies.new.page_title")
      @active_nav = "companies"

      render :new, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :address
    )
  end
end
