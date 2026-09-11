class PermissionMailer < ApplicationMailer
  def role_changed(recipient:, affected_user:, actor:, old_role_ids:, new_role_ids:) # user:,... - keyword argument
    @recipient = recipient
    @affected_user = affected_user
    @actor = actor


    @old_roles = Role.where(id: old_role_ids).order(:name)
    @new_roles = Role.where(id: new_role_ids).order(:name)

    I18n.with_locale(I18n.locale) do
      mail(
        to: @recipient.email,
        subject: I18n.t("mailers.permission.role_changed.subject")
      )
    end
  end
end
