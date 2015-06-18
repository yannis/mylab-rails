class Sharing < ActiveRecord::Base
  belongs_to :sharable, polymorphic: true
  belongs_to :group, inverse_of: :sharings

  validates_presence_of :group
  validates_presence_of :sharable
  validates_uniqueness_of :group, scope: [:sharable_id, :sharable_type]

  validates_each :group_id do |sharing, attr, value|
    if sharing.sharable.present? && sharing.group.present? && !sharing.sharable.sharable_with_group?(sharing.group)
      sharing.errors.add attr, ": You're not member of this group"
    end
  end
end
