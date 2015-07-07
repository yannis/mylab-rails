require 'rails_helper'

RSpec.describe Sharing, type: :model do
  describe "validation" do
    subject { create :sharing }
    it {is_expected.to belong_to :sharable}
    it {is_expected.to belong_to :group}
    it {is_expected.to validate_presence_of :sharable}
    it {is_expected.to validate_presence_of :group}
    it {is_expected.to validate_uniqueness_of(:group).scoped_to(:sharable_id, :sharable_type)}
  end

  describe "A sharing with a group I'm not a member is not valid" do
    let(:user){create :user}
    let(:document){create :document, user: user}
    let(:group){create :group}
    let(:sharing) {build :sharing, sharable_type: "Document", sharable_id: document.id, group: group}

    before {sharing.valid?}
    it{expect(sharing).to_not be_valid}
    it{expect(sharing.errors.full_messages_for(:group_id).to_sentence).to match /Group : You must be a member of this group/ }
  end
end
