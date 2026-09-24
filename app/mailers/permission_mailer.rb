class PermissionMailer < ApplicationMailer
  def role_changed(params)
    @recipient = params[:recipient]
    @affected_user = params[:affected_user]
    @actor = params[:actor]

    old_role_ids = params[:old_role_ids]
    new_role_ids = params[:new_role_ids]

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
