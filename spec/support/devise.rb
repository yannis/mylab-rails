RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :helper
  config.include Devise::TestHelpers, type: :view


  def should_not_authorize
    expect(response.status).to eql 403
    expect(response.body).to eql '{"errors":"You are not authorized to access this page."}'
  end

  # def should_be_asked_to_sign_in
  #   response.should redirect_to '/sign_in'
  #   flash[:alert].should  =~ /Please sign in/
  # end

  # def sign_in_user
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   sign_out :user
  #   @admin = FactoryGirl.create :user, :role => "admin", :name => 'user'
  #   sign_in @admin
  # end

  # def sign_in_basic_user(user=nil)
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   sign_out :user
  #   @basic = user.presence || FactoryGirl.create(:user, :name => 'basic_user', :role => 'basic')
  #   sign_in @basic
  # end

  # def sign_in_admin_user(user=nil)
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   sign_out :user
  #   @admin = user.presence || FactoryGirl.create(:user, :name => 'admin_user', :role => 'admin')
  #   sign_in @admin
  # end

  # def sign_in_labadmin_user(user=nil)
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   sign_out :user
  #   @labadmin = user.presence || FactoryGirl.create(:user, :name => 'labadmin_user', :role => 'labadmin')
  #   sign_in @labadmin
  # end

  # def sign_in_labuser
  #   @request.env["devise.mapping"] = Devise.mappings[:user]
  #   sign_out :user
  #   @labadmin = FactoryGirl.create(:user, :name => 'labuser', :role => 'labadmin')
  #   sign_in @labadmin
  # end

end

# RSpec.configure do |config|
#   config.include Devise::TestHelpers, type: :controller
#   config.include Devise::TestHelpers, type: :helper
#   config.include Devise::TestHelpers, type: :view


#   def sign_in_admin_user
#     @request.env["devise.mapping"] = Devise.mappings[:user]
#     sign_out :user
#     @admin = FactoryGirl.create :user, role: "admin", name: 'admin_user'
#     sign_in @admin
#   end

#   def sign_in_basic_user(user=nil)
#     @request.env["devise.mapping"] = Devise.mappings[:user]
#     sign_out :user
#     @basic = user.presence || FactoryGirl.create(:user, name: 'basic_user', role: 'basic')
#     sign_in @basic
#   end

#   def sign_in_labadmin_user
#     @request.env["devise.mapping"] = Devise.mappings[:user]
#     sign_out :user
#     @labadmin = FactoryGirl.create(:user, name: 'labadmin_user', role: 'labadmin')
#     sign_in @labadmin
#   end

#       # see http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/
#   Devise.stretches = 1

#   def should_be_asked_to_sign_in
#     response.should redirect_to '/sign_in'
#     flash[:alert].should  =~ /Please sign in/
#   end

#   def should_not_authorize(user)
#     response.should redirect_to user
#     should set_flash.to(/You are not authorized to access this page/)
#   end

#   def signin(user)
#     visit '/users/sign_in'
#     if page.has_selector?("form#new_user[action='/users/sign_in']")
#        # current_path == '/users/sign_in'
#       fill_in "user_email", with: user.email
#       fill_in "user_password", with: user.password
#       click_button :user_submit
#     end
#     # page.should have_content('Signed in successfully.')
#   end

#   def signin_and_visit(user, url)
#     uri = URI.parse(current_url)
#     visit url
#     if page.has_selector?("form#new_user[action='/users/sign_in']")
#       fill_in "user_email", with: user.email
#       fill_in "user_password", with: user.password
#       click_button :user_submit
#       visit url
#     end
#   end

#   def flash_should_contain(text)
#     page.find("div#flash").should have_content text
#   end

# end
