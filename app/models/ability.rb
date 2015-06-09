class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)

    group_ids = user.groups.pluck(:id)
    admin_group_ids = user.admin_groups.pluck(:id)

    if user.admin?
        can :manage, :all
    else

      # attachments
      can :read, Attachment, attachable: {user_id: user.id}
      can :read, Attachment, attachable: {groups: {id: group_ids}}
      can :create, Attachment, attachable: {user_id: user.id}
      can :update, Attachment, attachable: {user_id: user.id}
      can :update, Attachment, attachable: {groups: {id: group_ids}}
      can :destroy, Attachment, attachable: {user_id: user.id}

      # categories
      can :read, Category
      can :create, Category
      # can :update, Category
      can :destroy, Category, {documents: {category_id: nil}}

      # documents
      can :read, Document, {user_id: user.id}
      can :read, Document, {groups: {id: group_ids}}
      can :create, Document, {user_id: user.id}

      can :update, Document, {user_id: user.id}
      can :update, Document, {groups: {id: admin_group_ids}}

      can :destroy, Document, {user_id: user.id}

      # groups
      # can :read, Group, {id: group_ids}
      can :read, Group, {id: group_ids}
      can :create, Group
      can :update, Group, {id: admin_group_ids}
      can :destroy, Group, {id: admin_group_ids}

      # invitations
      can [:read, :create, :destroy], Invitation, {inviter_id: user.id}
      can [:read, :destroy], Invitation, {group_id: admin_group_ids}
      can [:read], Invitation, {invited_id: user.id}
      can [:update], Invitation, {invited_id: user.id, state: nil}

      # memberships
      can :read, Membership, {group_id: group_ids}
      can :create, Membership, {group_id: admin_group_ids}
      can :update, Membership, {group_id: admin_group_ids}
      can :destroy, Membership, {group_id: admin_group_ids}

      # pictures
      can :read, Picture, picturable: {user_id: user.id}
      can :read, Picture, picturable: {groups: {id: group_ids}}
      can :create, Picture, picturable: {user_id: user.id}
      can :update, Picture, picturable: {user_id: user.id}
      can :update, Picture, picturable: {groups: {id: group_ids}}
      can :destroy, Picture, picturable: {user_id: user.id}

      # sharings
      can :read, Sharing, sharable: {user_id: user.id}
      can :read, Sharing, group: {memberships: {user_id: user.id}}
      can :create, Sharing
      can :destroy, Sharing, sharable: {user_id: user.id}

      # users
      can :read, User, id: user.id
      # can :create, User
      can :read, User, {memberships: {group_id: group_ids}}
      can :update, User, id: user.id

      # versions
      can :read, Version, {document: {user_id: user.id}}
      can :read, Version, {document: {groups: {id: group_ids}}}

      can :create, Version, {document: {user_id: user.id}}
      can :create, Version, {document: {groups: {id: admin_group_ids}}}

      can :update, Version, {document: {user_id: user.id}}
      can :update, Version, {document: {groups: {id: admin_group_ids}}}

      can :destroy, Version, {document: {user_id: user.id}}
      can :destroy, Version, {document: {groups: {id: admin_group_ids}}}
    end
  end
end
