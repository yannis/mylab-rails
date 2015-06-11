require 'rails_helper'

RSpec.describe API::V1::UsersController, type: :controller do

  context "Not signed in" do
    context "with 3 users in the database" do

      3.times do |i|
        let!("user_#{i+1}".to_sym){create :user}
      end

      describe "GET 'index'" do
        before { xhr :get, 'index'}
        it { should_not_authorize }
      end

      describe "GET 'show'" do
        before { xhr :get, 'show', id: user_1.id}
        it { should_not_authorize }
      end

      describe "POST 'create'" do
        before { xhr :post, 'create', user: {name: "a new user", email: "anemail@email.ch", password: "password"}}
        it { should_not_authorize }
      end

      describe "PUT 'update'" do
        before { xhr :put, 'update', id: user_1.id, user: {name: "updated name"}}
        it { should_not_authorize }
      end

      describe "DELETE 'destroy'" do
        before {
          @user_count = User.count
          xhr :delete, :destroy, id: user_1.id
        }
        it { should_not_authorize }
        it {expect(@user_count-User.count).to eq(0)}
      end
    end
  end

  context "Signed in as basic" do

    let(:user) { create :user }
    before { sign_in(user) }

    context "with 3 users in the database" do

      3.times do |i|
        let!("user_#{i+1}".to_sym){create :user}
      end

      describe "GET 'index'" do
        before { xhr :get, 'index' }
        it { expect(response).to be_success }
        it {expect(assigns(:users).to_a).to match_array [user]}
      end

      describe "GET 'show' for current_user" do
        before { xhr :get, 'show', id: user.id}
        it { expect(response).to be_success }
        it {expect(assigns(:user)).to eql user}
      end

      describe "GET 'show' for another user" do
        before { xhr :get, 'show', id: user_1.id}
        it { should_not_authorize }
      end

      describe "POST 'create'" do
        before { xhr :post, 'create', user: {name: "a new user", email: "anemail@email.ch", password: "password"}}
        it { should_not_authorize }
      end

      describe "POST 'create' with token and invitation" do
        let(:email) {"email@email.ch"}
        let!(:invitation) {create :invitation, email: email}
        before {
          @user_count = User.count
          xhr :post, 'create', user: {name: "a new user", password: "password", invitation_id: invitation.id, token: invitation.token}
        }
        it {expect(assigns(:user).name).to eql "a new user"}
        it {expect(assigns(:user)).to be_valid}
        it {expect(User.count-@user_count).to eql 1}
        it {expect(invitation).to_not be_accepted}
        it {expect(invitation.reload).to be_accepted}
      end

      describe "PUT 'update' another user" do
        before { xhr :put, :update, id: user_1.id, user: {name: "updated name"}}
        it { should_not_authorize }
      end

      describe "PUT 'update' current_user" do
        before { xhr :put, :update, id: user.id, user: {name: "updated name"}}
        it {expect(response).to be_success}
        it {expect(user.reload.name).to eql "updated name"}
      end

      describe "DELETE 'destroy' another user" do
        before {
          xhr :delete, :destroy, id: user_1.id
        }
        it { should_not_authorize }
      end

      describe "DELETE 'destroy' current_user" do
        before {
          xhr :delete, :destroy, id: user.id
        }
        it { should_not_authorize }
      end
    end
  end

  context "Signed in as admin" do

    let(:user) { create :user, admin: true }
    before { sign_in(user) }

    context "with 3 users in the database" do

      3.times do |i|
        let!("user_#{i+1}".to_sym){create :user}
      end

      describe "GET 'index'" do
        before { xhr :get, 'index' }
        it { expect(response).to be_success }
        it {expect(assigns(:users).to_a).to match_array [user, user_1, user_2, user_3]}
      end

      describe "GET 'show'" do
        before { xhr :get, 'show', id: user_1.id}
        it { expect(response).to be_success }
        it {expect(assigns(:user)).to eql user_1}
      end

      describe "POST 'create'" do
        before { xhr :post, 'create', user: {name: "a new user", email: "anemail@email.ch", password: "password"}}
        it { expect(response).to be_success}
        it {expect(assigns(:user).name).to eql "a new user"}
        it {expect(assigns(:user)).to be_valid}
      end

      describe "PUT 'update'" do
        before { xhr :put, :update, id: user_1.id, user: {name: "updated name"}}
        it {expect(response).to be_success}
        it {expect(user_1.reload.name).to eql "updated name"}
      end

      describe "DELETE 'destroy'" do
        before {
          @user_count = User.count
          xhr :delete, :destroy, id: user_1.id
        }
        it {expect(response).to be_success}
        it {expect(@user_count-User.count).to eq(1)}
      end
    end
  end
end
