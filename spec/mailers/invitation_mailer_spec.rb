require "rails_helper"

RSpec.describe InvitationMailer, type: :mailer do
  describe "invite_existing_user" do
    let(:invitation) {create :invitation}
    let(:mail) { InvitationMailer.invite_existing_user invitation.id }

    it "renders the headers" do
      expect(mail.subject).to eq("#{invitation.inviter.name} invited you to group myLab group '#{invitation.group.name}'")
      expect(mail.to).to eq([invitation.invited.email])
      expect(mail.from).to eq([ENV['MAILER_SENDER']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{invitation.invited.name},")
    end
  end

  describe "invite_new_user" do
    let(:invitation) {create :invitation, invited: nil, email: Faker::Internet.email}
    let(:mail) { InvitationMailer.invite_new_user invitation.id }

    it "renders the headers" do
      expect(mail.subject).to eq("#{invitation.inviter.name} invited you to use myLab, a document sharing application")
      expect(mail.to).to eq([invitation.email])
      expect(mail.from).to eq([ENV['MAILER_SENDER']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi #{invitation.email},")
    end
  end

end
