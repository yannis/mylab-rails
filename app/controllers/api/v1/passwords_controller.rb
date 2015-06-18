class API::V1::PasswordsController < Devise::PasswordsController

  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_api_v1_user!

  def new
    super
  end

  def create
    resource = resource_class.send_reset_password_instructions(resource_params)
    if resource.persisted?
      render json: {success: "You will receive an email with instructions about how to reset your password within few minutes."}, status: 201
    else
      render json: {errors: resource.errors}, status: :unprocessable_entity
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      render json: resource, serializer: API::V1::UserSerializer
      # render json: {success: "Password successfully updated."}, status: 201
      # if Devise.sign_in_after_reset_password
      #   sign_in(resource_name, resource)
      #   respond_with resource, location: after_resetting_password_path_for(resource)
      # else
      #   set_flash_message(:notice, :updated_not_active) if is_flashing_format?
      #   respond_with resource, location: new_session_path(resource_name)
      # end
    else
      render json: {errors: resource.errors}, status: :unprocessable_entity
    end
  end

  private

    def resource_params
      params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
    end
end
