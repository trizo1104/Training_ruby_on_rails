class UserPolicy < ApplicationPolicy
  def index?
    user.has_permission?("user", "view")
  end

  def show?
    user.has_permission?("user", "view")
  end

  def create?
    user.has_permission?("user", "create")
  end

  def update?
    user.has_permission?("user", "update")
  end

  def destroy?
    user.has_permission?("user", "delete")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_permission?("user", "view_all")
        scope.all
      elsif user.has_permission?("user", "view")
        scope.where(
          company_id: user.company_id,
          manager_id: user.id
        )
      else
        scope.none
      end
    end
  end
end
