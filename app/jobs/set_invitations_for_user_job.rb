class SetInvitationsForUserJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find user_id
    if user
      Invitation.where(email: user.email).each do |invitation|
        invitation.update_attributes!(invited: user)
      end
    end
  end
end
