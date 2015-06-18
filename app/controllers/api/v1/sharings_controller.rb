class API::V1::SharingsController < ApplicationController

  load_and_authorize_resource :group
  load_and_authorize_resource :sharing, through: [:group], shallow: true, param_method: :sanitizer

  respond_to :json

  def index
    respond_with @sharings, each_serializer: API::V1::SharingSerializer
  end

  def show
    respond_with @sharing, serializer: API::V1::SharingSerializer
  end

  def create
    if @sharing.save
      render json: @sharing, serializer: API::V1::SharingSerializer, status: :created
    else
      render json: {errors: @sharing.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @sharing.destroy
  end

private

  def sanitizer
    params.require(:sharing).permit(:group_id, :sharable_id, :sharable_type)
  end

end
