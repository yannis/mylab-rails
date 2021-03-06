class API::V1::MembershipsController < ApplicationController

  load_and_authorize_resource :user
  load_and_authorize_resource :membership, through: [:user], shallow: true, param_method: :sanitizer

  respond_to :json

  def index
    respond_with @memberships.includes(:group), each_serializer: API::V1::MembershipSerializer
  end

  def show
    respond_with @membership, serializer: API::V1::MembershipSerializer
  end

  def create
    if @membership.save
      render json: @membership, serializer: API::V1::MembershipSerializer, status: :created
    else
      render json: {errors: @membership.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @membership.update_attributes sanitizer
      render json: @membership, serializer: API::V1::MembershipSerializer, status: :created
    else
      render json: {errors: @membership.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    if @membership.destroy
      render json: @membership, serializer: API::V1::MembershipSerializer, status: 200
    else
      render json: {errors: @membership.errors}, status: :unprocessable_entity
    end
  end

private

  def sanitizer
    params.require(:membership).permit(:role, :user_id, :group_id)
  end

end
