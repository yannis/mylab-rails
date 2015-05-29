class API::V1::UsersController < ApplicationController

  load_and_authorize_resource :user, param_method: :sanitizer, except: [:show, :create]

  def index
    render json: @users, each_serializer: API::V1::UserSerializer
  end

  def show
    if params[:token] && params[:id]
      @user = User.where(id: params[:id], authentication_token: params[:token]).first
    else
      authorize! :read, User
      @user = User.accessible_by(current_ability, :read).find(params[:id])
    end
    render json: @user, serializer: API::V1::UserSerializer
  end

  def create
    @user = User.new sanitizer
    if params[:user][:token] && params[:user][:invitation_id]
      invitation = Invitation.pending.where(id: params[:user][:invitation_id], token: params[:user][:token]).first
      if invitation.blank?
        @user.errors.add :base, "You're not authorized to create a user"
      end
    else
      authorize! :create, User
    end
    if @user.save
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
    render json: @user.destroy
  end
private

  def sanitizer
    params.require(:user).permit(:name, :email, :password)
  end
end
