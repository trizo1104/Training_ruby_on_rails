class Permission::RoleChangedJob < ApplicationJob
  queue_as :default # method queue_as recive an argumnent :default (type symbol)

  def perform(affected_user_id, actor_id, old_role_ids, new_role_ids)
    affected_user = User.find(affected_user_id)
    actor = User.find(actor_id)

    PermissionMailer.role_changed(
      recipient: affected_user,
      affected_user: affected_user,
      actor: actor,
      old_role_ids: old_role_ids,
      new_role_ids: new_role_ids
    ).deliver_now

    return if affected_user.id == actor.id

    PermissionMailer.role_changed(
      recipient: actor,
      affected_user: affected_user,
      actor: actor,
      old_role_ids: old_role_ids,
      new_role_ids: new_role_ids
    ).deliver_now
  end
end


# The job itself is already executed in the background,
# so use deliver_now instead of enqueueing another mail job.
# 
# Async Adapter (stored on rails memmory). Other support system like: sold queue, sidekiq