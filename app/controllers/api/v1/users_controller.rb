class API::V1::UsersController < ApplicationController

  load_and_authorize_resource :user, param_method: :sanitizer, except: [:create, :show]

  def index
    respond_with @users, each_serializer: API::V1::UserSerializer
  end

  def show
    @user = User.where(id: params[:id]).includes(:invitations_as_inviter, :invitations_as_invited, :documents).accessible_by(current_ability).first
    authorize! :read, @user
    respond_to do |format|
      format.json {
        render json: @user, serializer: API::V1::UserSerializer
      }
    end
  end

  def create
    @user = User.new sanitizer
    if params[:user][:token].present? && params[:user][:invitation_id].present?
      invitation = Invitation.pending.where(id: params[:user][:invitation_id], token: params[:user][:token]).first
      @user.email = invitation.email
      if invitation.blank?
        @user.errors.add :base, "You're not authorized to create a user"
      end
    else
      authorize! :create, User
    end
    if @user.save
      if invitation
        invitation.accept!
      end
      render json: @user, serializer: API::V1::UserSerializer, status: :created
    else
      render json: {errors: @user.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @user.update_attributes sanitizer
      render json: @user, serializer: API::V1::UserSerializer, status: :created
    else
      render json: {errors: @user.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @user.destroy
  end
private

  def sanitizer
    params.require(:user).permit(:name, :email, :password)
  end
end
