require 'rails_helper'

RSpec.describe Invitation, type: :model do
  before {create :invitation}
  it {is_expected.to belong_to :inviter}
  it {is_expected.to belong_to :invited}
  it {is_expected.to belong_to :group}
  it {is_expected.to validate_presence_of :inviter}
  it {is_expected.to validate_presence_of :group}
  it {is_expected.to validate_uniqueness_of(:invited_id).scoped_to(:group_id)}
end

RSpec.describe Invitation, type: :model do

  describe "An invitation made by an admin" do
    let(:user){create :user}
    let(:group){create :group}
    let!(:membership) { create :membership, role: 'admin', group: group, user: user }
    let(:invitation) {create :invitation, group: group, inviter: user, invited: create(:user)}

    it {expect(invitation).to be_valid}
    it {expect(invitation).to be_pending}
    it {expect(Invitation.pending).to include invitation}
    it{expect(Invitation.accepted).to_not include invitation}
    it{expect(Invitation.declined).to_not include invitation}
  end

  describe "An invitation not made by an admin" do
    let(:user){create :user}
    let(:group){create :group}
    let!(:membership) { create :membership, role: 'admin', group: group, user: user }
    let(:invitation) {build :invitation, group: group, inviter: create(:user), invited: create(:user)}

    before {invitation.valid?}

    it {expect(invitation).to_not be_valid}
    it {expect(invitation.errors[:inviter_id]).to match_array [": not admin of group '#{invitation.group.name}'"]}
    it {expect(invitation.errors.full_messages).to match_array ["Inviter : not admin of group '#{invitation.group.name}'"]}
  end

  describe "Accepting an invitation" do
    let!(:invitation) {create :invitation}

    before {
      @membership_count = Membership.count
      invitation.accept!
    }

    it{expect(invitation).to be_accepted}
    it{expect(Invitation.accepted).to include invitation}
    it{expect(Invitation.declined).to_not include invitation}
    it{expect(Invitation.pending).to_not include invitation}
    it{expect(invitation).to_not be_pending}
    it{expect(invitation).to_not be_declined}
    it{expect(Membership.count-@membership_count).to eql 1}
  end

  describe "declining an invitation already accepted" do
    let!(:invitation) {create :invitation, state: "accepted", state_at: 2.hours.ago}
    before {
      invitation.decline!
    }

    it{ expect(invitation).to_not be_valid }
    it{ expect(invitation.errors.full_messages.to_sentence).to eql "This invitation has already been accepted" }
  end

  describe "accepting an invitation already accepted" do
    let!(:invitation) {create :invitation, state: "accepted", state_at: 2.hours.ago}
    before {
      invitation.accept!
    }
    it{ expect(invitation).to_not be_valid }
    it{ expect(invitation.errors.full_messages.to_sentence).to eql "This invitation has already been accepted" }
  end

  describe "accepting an invitation already declined" do
    let!(:invitation) {create :invitation, state: "declined", state_at: 2.hours.ago}
    before {
      invitation.decline!
    }

    it{ expect(invitation).to_not be_valid }
    it{ expect(invitation.errors.full_messages.to_sentence).to eql "This invitation has already been declined" }
  end

  describe "declining an invitation already declined" do
    let!(:invitation) {create :invitation, state: "declined", state_at: 2.hours.ago}
    before {
      invitation.accept!
    }
    it{ expect(invitation).to_not be_valid }
    it{ expect(invitation.errors.full_messages.to_sentence).to eql "This invitation has already been declined" }
  end

  describe "Declining an invitation" do
    let!(:invitation) {create :invitation}

    before {
      @membership_count = Membership.count
      invitation.decline!
    }

    it{expect(invitation).to be_declined}
    it{expect(invitation).to_not be_pending}
    it{expect(invitation).to_not be_accepted}
    it{expect(Membership.count-@membership_count).to eql 0}
  end

  describe "Inviting an existing user by email" do
    let(:invited) { create :user }
    let(:invitation) {create :invitation, email: invited.email, invited: nil}
    it {expect(invitation.invited).to eql invited}
  end

  describe "Inviting an existing user should send an email" do
    include ActiveJob::TestHelper
    before {
      ActionMailer::Base.deliveries = []
      clear_enqueued_jobs
      invitation.save
    }
    after {clear_enqueued_jobs}
    let!(:invited) { create :user }
    let(:invitation) {build :invitation, email: invited.email, invited: nil}

    it 'should email' do
      perform_enqueued_jobs do
        delivered_email = ActionMailer::Base.deliveries.first
        assert_includes delivered_email.to, invited.email
      end
    end
  end

  describe "Inviting an new user should send an email" do
    include ActiveJob::TestHelper
    before {
      ActionMailer::Base.deliveries = []
      clear_enqueued_jobs
      invitation.save
    }
    after {clear_enqueued_jobs}
    let(:invitation) {build :invitation, email: "anemail@email.com", invited: nil}

    it 'should email' do
      perform_enqueued_jobs do
        delivered_email = ActionMailer::Base.deliveries.first
        assert_includes delivered_email.to, invitation.email
      end
    end
  end
end
