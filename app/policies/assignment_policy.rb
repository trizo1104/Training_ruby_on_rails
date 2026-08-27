class AssignmentPolicy < ApplicationPolicy
  def create?
    user.has_permission?("assignment", "create")
  end

  def show?
    user.has_permission?("assignment", "view") &&
      record.user_id == user.id
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
      if user.has_permission?("assignment", "read_all")
        scope.all
      elsif user.has_permission?("assignment", "view")
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
