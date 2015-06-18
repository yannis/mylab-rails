FactoryGirl.define do
  factory :sharing do
    association :sharable, factory: :document
    # sharable_type "Document"
    # sharable_id {create(:document).id}
    group {|s| create(:group, memberships: [build(:membership, user: s.sharable.user)])}
  end
end
