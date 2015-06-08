class Membership < ActiveRecord::Base
  belongs_to :user, inverse_of: :memberships
  belongs_to :group, inverse_of: :memberships

  MEMBERSHIP_ROLES = %w{admin basic}

  validates_presence_of :user
  validates_uniqueness_of :user, scope: :group_id
  validates_presence_of :group
  validates_presence_of :role
  validates_inclusion_of :role, in: MEMBERSHIP_ROLES

  validates_each :role do |record, attr, value|
    group = record.group
    if group
      group_memberships_admin = group.memberships.admin
      admin_counts = group_memberships_admin.count
      group_last_admin_membership = group.memberships.admin.last
      if record.role_changed? && record.role == 'basic' && record.role_was == 'admin' && admin_counts == 1 && group_last_admin_membership == record
        record.errors.add attr, ": This membership is the last admin membership of this group. You can't change it to 'basic'"
      end
    end
  end

  def self.admin
    where(role: "admin")
  end

  def self.basic
    where(role: "basic")
  end

  def self.of_group(group)
    where(group: group)
  end

  def self.of_user(user)
    where(user: user)
  end

  def destroy
    unless can_destroy
      raise "Cannot destroy the last membership of a group"
      return false
    end
    super
  end

  def admin?
    role.to_s == "admin"
  end

  def basic?
    role.to_s == "basic"
  end

private

  def can_destroy
    memberships_count = self.group.memberships.count
    admin_memberships_count = self.group.memberships.admin.count
    if self.marked_for_destruction?
      return true
    end
    if memberships_count == 1
      return false
    elsif self.admin? && admin_memberships_count == 1
      return false
    end
    return true
  end
end
