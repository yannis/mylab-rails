class API::V1::SessionsController < Devise::SessionsController

  skip_before_filter :authenticate_user_from_token!
  skip_before_filter :authenticate_api_v1_user!

  def create
    user = User.includes({memberships: [:group]}).find_for_database_authentication(email: params[:user][:email])
    if user && user.valid_password?(params[:user][:password])
      user.update_attributes authentication_token: Devise.friendly_token
      sign_in user

      data = {
        token:    user.authentication_token,
        email:    user.email,
        id:       user.id
      }
      render json: data, status: 201
    else
      render json: {errors: "Invalid email or password"}, status: :unprocessable_entity
    end
  end

  # def create
  #   respond_to do |format|
  #     format.json do
  #       self.resource = warden.authenticate!(auth_options)
  #       sign_in(resource_name, resource)
  #       @data = {
  #         token: self.resource.authentication_token,
  #         user_email: self.resource.email,
  #         user_id: self.resource.id
  #       }
  #       render json: @data.to_json, status: 201
  #     end
  #   end
  # end

end
