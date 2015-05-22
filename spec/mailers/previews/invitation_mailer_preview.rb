# Preview all emails at http://localhost:3000/rails/mailers/invitation
class InvitationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/invitation/invite
  def invite_existing_user
    InvitationMailer.invite_existing_user(Invitation.first.id)
  end
  def invite_new_user
    InvitationMailer.invite_existing_user(Invitation.first.id)
  end

end
