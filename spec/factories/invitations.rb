FactoryGirl.define do
  factory :invitation do |i|
    # group = Group.create(name: Faker::Company.name)
    i.inviter { create(:user, memberships: [create(:membership, group: group, role: 'admin')]) }
    i.association :group
    i.association :invited, factory: :user
    i.email nil
  end
end
