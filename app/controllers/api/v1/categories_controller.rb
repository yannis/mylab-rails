class API::V1::CategoriesController < ApplicationController

  load_and_authorize_resource :category, param_method: :sanitizer

  respond_to :json

  def index
    meta = {}
    if params[:search].present? && params[:search] != 'undefined'
      @categories = @categories.where("LOWER(categories.name) LIKE ?", "%#{params[:search].downcase}%")
    end
    if params[:page].present?
      page = (params[:page].presence || 1).to_i
      per_page = (params[:per_page].presence || 10).to_i
      @categories = @categories.page(page).per(per_page)
      meta[:total_pages] = @categories.total_pages
    end
    respond_with @categories, each_serializer: API::V1::CategorySerializer, meta: meta
  end

  def show
    respond_with @category, serializer: API::V1::CategorySerializer
  end

  def create
    if @category.save
      render json: @category, serializer: API::V1::CategorySerializer, status: :created
    else
      render json: {errors: @category.errors}, status: :unprocessable_entity
    end
  end

  def update
    @category.update_attributes sanitizer
    respond_with @category
  end

  def destroy
    respond_with @category.destroy
  end


private

  def sanitizer
    params.require(:category).permit(:name)
    # if current_user.present?
    #   if current_user.admin?
    #     params.require(:user).permit!
    #   elsif current_user.member?
    #     params.require(:user).permit(:id, :name, :description)
    #   end
    # end
  end

end
