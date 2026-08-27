class UserPolicy < ApplicationPolicy
  def index?
    user.has_permission?("user", "view")
  end

  def show?
    # user.has_permission?("user", "view")
    return true if user.id == record.id

    return false unless user.has_permission?("user", "view")

    if user.has_permission?("user", "view_all")
      true
    else
      record.company_id == user.company_id &&
        record.manager_id == user.id
    end
  end

  def create?
    user.has_permission?("user", "create")
  end

  def update?
    # user.has_permission?("user", "update")
    return true if user.id == record.id

    return false unless user.has_permission?("user", "update")

    record.company_id == user.company_id &&
      record.manager_id == user.id
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user.has_permission?("user", "delete")

    record.company_id == user.company_id &&
    record.manager_id == user.id
  end

  def assign_role?
    user.has_permission?("user", "assign_role")
  end

  def manage_rbac?
    user.has_permission?("rbac", "manage")
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
