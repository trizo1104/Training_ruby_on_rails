class AssignmentPolicy < ApplicationPolicy
  def create?
    user.has_permission?("assignment", "create")
  end

  def new?
    create?
  end

  def show?
    user.has_permission?("assignment", "view") &&
      accessible_record?
  end

  def update?
    user.has_permission?("assignment", "update") &&
      record.user_id == user.id
  end

  def destroy?
    user.has_permission?("assignment", "delete") &&
      record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user.has_permission?("assignment", "view")

      if user.has_role?("Admin")
        scope.all
      elsif user.has_role?("Manager")
        scope.where(company_id: user.company_id)
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def accessible_record?
    if user.has_role?("Admin")
      true
    elsif user.has_role?("Manager")
      record.company_id == user.company_id
    else
      record.user_id == user.id
    end
  end
end
