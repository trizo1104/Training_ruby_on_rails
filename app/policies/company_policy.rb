class CompanyPolicy < ApplicationPolicy
  def index?
    user.has_permission?("company", "view")
  end

  def show?
    user.has_permission?("company", "view")
  end

  def create?
    user.has_permission?("company", "create")
  end

  def update?
    user.has_permission?("company", "update")
  end

  def destroy?
    user.has_permission?("company", "delete")
  end

  class Scope < ApplicationPolicy::Scope
  def resolve
    if user.has_permission?("company", "read_all")
      scope.all
    elsif user.has_permission?("company", "view")
      scope.where(id: user.company_id)
    else
      scope.none
    end
  end
  end
end
