class UsersController < ApplicationController
  before_action :authenticate_user!

  # def index
  #   @page_title = t("users.index.page_title")
  #   @active_nav = "users"

  #   @users = policy_scope(User)

  #   if current_user.has_role?("Admin")
  #     prepare_rbac_data
  #   end

  #   @pagy, @users = pagy(:offset, @users, limit: 5)
  # end

  def index
    authorize User

    scope = policy_scope(User)

    if params[:search].present?
      scope = scope.where(
        "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q",
        q: "%#{params[:search]}%"
      )
    end

    @pagy, @users = pagy(
      scope
        .includes(:roles, :company, :manager)
        .order(:first_name, :last_name)
    )

    if current_user.has_role?("Admin")
      @roles = Role
        .includes(:permissions)
        .order(:name)

      @permissions = Permission
        .order(:resource, :action)
        .group_by(&:resource)
    end
  end

  def show
    @page_title = t("users.show.page_title")
    @active_nav = params[:id].present? ? "users" : "profile"

    @user =
      if params[:id].present?
        User.find_by!(id: params[:id])
      else
        current_user
      end

    authorize @user, :show?
  end

  def new
    @user = User.new

    authorize @user, :new?

    prepare_user_form
  end

  def create
    @user = User.new(user_params)

    authorize @user, :create?

    role = resolve_user_role

    company, manager = resolve_user_relationships(role)

    Users::Creator.new(
      user: @user,
      role: role,
      company: company,
      manager: manager
    ).call

    redirect_to user_path(@user),
                notice: t("users.create.success")

  rescue ActiveRecord::RecordInvalid # try-catch exception to catch failure situation
    prepare_user_form
    render :new, status: :unprocessable_entity
  end

  def edit
    # @user = User.find_by!(id: params[:id])

    @user =
      if params[:id].present?
        User.find_by!(id: params[:id])
      else
        current_user
      end

    authorize @user, :edit?

    prepare_user_form
  end

  def update
    @user = User.find_by!(id: params[:id])

    authorize @user, :update?

    if @user.update(user_params)
      redirect_to user_path(@user),
                  notice: t("users.update.success")
    else
      prepare_user_form

      render :edit, status: :unprocessable_entity
    end
  end

  def managers
    company = Company.find(params[:company_id])

    managers = company.users
                      .joins(:roles)
                      .where(roles: { name: "Manager" })
                      .order(:first_name, :last_name)

    render json: managers.map { |manager|
      {
        id: manager.id,
        name: manager.full_name
      }
    }
  end

  private
    def prepare_user_form
      @is_admin = current_user.has_role?("Admin")

      return unless @is_admin

      @roles = Role.order(:name)
      @companies = Company.order(:name)

      company_id = params.dig(:user, :company_id)

      @managers =
        if company_id.present?
          User.joins(:roles)
              .where(company_id: company_id)
              .where(roles: { name: "Manager" })
              .order(:first_name, :last_name)
        else
          User.none
        end
    end

    def resolve_user_relationships(role)
      if current_user.has_role?("Admin")
        resolve_admin_relationships(role)
      else
        resolve_manager_relationships
      end
    end

    def resolve_admin_relationships(role)
      company = Company.find(user_params[:company_id])

      manager =
        if role.name == "Employee"
          company.users
                .joins(:roles)
                .where(roles: { name: "Manager" })
                .find(user_params[:manager_id])
        end

      [ company, manager ]
    end

    def resolve_user_role
      if current_user.has_role?("Admin")
        Role.find(params[:user][:role_id])
      else
        Role.find_by!(name: "Employee")
      end
    end

    def resolve_manager_relationships
      [
        current_user.company,
        current_user
      ]
    end

    def prepare_rbac_data
      @roles = Role.order(:name)

      @permissions = Permission.order(:resource, :action)
    end

    def user_params
      params.require(:user).permit(
        :email,
        :username,
        :first_name,
        :last_name,
        :department,
        :avatar,
        :password,
        :password_confirmation,
        :company_id,
        :manager_id,
      )
    end
end
