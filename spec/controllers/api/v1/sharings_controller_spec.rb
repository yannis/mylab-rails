require 'rails_helper'

RSpec.describe API::V1::SharingsController, type: :controller do

  let(:basic_group1) { create :group}
  let(:basic_group2) { create :group}
  let(:admin_group1) { create :group}
  let(:admin_group2) { create :group}

  let(:basic_user) { create :user, admin: false}
  let(:admin_user) { create :user, admin: true}

  let!(:admin_user_admin_group1_membership) {create :membership, user: admin_user, group: admin_group1}
  let!(:basic_user_basic_group1_membership) {create :membership, user: basic_user, group: basic_group1}
  let!(:basic_user_basic_group2_membership) {create :membership, user: basic_user, group: basic_group2}

  let(:admin_document1) { create :document, user: admin_user}
  let(:admin_document2) { create :document, user: admin_user}
  let(:basic_document1) { create :document, user: basic_user}
  let(:basic_document2) { create :document, user: basic_user}

  let!(:admin_sharing1) {create :sharing, sharable: admin_document1, group: admin_group1}
  let!(:admin_sharing2) {create :sharing, sharable: admin_document2, group: admin_group1}
  let!(:basic_sharing1) {create :sharing, sharable: basic_document1, group: basic_group1}
  let!(:basic_sharing2) {create :sharing, sharable: basic_document2, group: basic_group1}

  # it {expect(admin_sharing1).to be_valid}
  # it {expect(admin_sharing2).to be_valid}
  # it {expect(basic_sharing1).to be_valid}
  # it {expect(basic_sharing2).to be_valid}

  context "Not signed in" do

    describe "GET 'index'" do
      before { xhr :get, 'index'}
      it { should_not_authorize }
    end

    describe "GET 'show'" do
      before { xhr :get, 'show', id: basic_sharing1.id}
      it { should_not_authorize }
    end

    describe "POST 'create'" do
      before { xhr :post, 'create', sharing: {sharable_id: basic_document1, sharable_type: "Document", group_id: admin_group1}}
      it { should_not_authorize }
    end

    describe "DELETE 'destroy'" do
      before {
        @sharing_count = Sharing.count
        xhr :delete, :destroy, id: basic_sharing1.id
      }
      it { should_not_authorize }
      it {expect(@sharing_count-Sharing.count).to eq(0)}
    end
  end

  context "Signed in as admin" do

    before { sign_in(admin_user) }

    describe "GET 'index'" do
      before { xhr :get, 'index'}
      it { expect(response).to be_success}
      it { expect(assigns(:sharings)).to match_array [admin_sharing1, admin_sharing2, basic_sharing1, basic_sharing2]}
    end

    describe "GET 'show'" do
      before { xhr :get, 'show', id: basic_sharing1.id}
      it { expect(response).to be_success}
      it { expect(assigns(:sharing)).to eql basic_sharing1}
    end

    describe "POST 'create' with valid data" do
      before { xhr :post, 'create', sharing: {sharable_id: basic_document1, sharable_type: "Document", group_id: basic_group2}}
      it { expect(response).to be_success}
      it {expect(assigns(:sharing).sharable).to eql basic_document1}
      it {expect(assigns(:sharing)).to be_valid}
    end

    describe "POST 'create' with invalid data" do
      before { xhr :post, 'create', sharing: {sharable_id: basic_document1, sharable_type: "Document", group_id: admin_group1}}
      it { expect(response).to be_unprocessable}
      it {expect(assigns(:sharing).sharable).to eql basic_document1}
      it {expect(assigns(:sharing)).to_not be_valid}
    end

    describe "DELETE 'destroy'" do
      before {
        @sharing_count = Sharing.count
        xhr :delete, :destroy, id: basic_sharing1.id
      }
      it { expect(response).to be_success}
      it {expect(@sharing_count-Sharing.count).to eq(1)}
    end
  end

  context "Signed in as basic" do

    before { sign_in(basic_user) }

    describe "GET 'index'" do
      before { xhr :get, 'index'}
      it { expect(response).to be_success}
      it {
        expect(assigns(:sharings)).to match_array [basic_sharing1, basic_sharing2]
      }
    end

    describe "GET 'show'" do
      before { xhr :get, 'show', id: basic_sharing1.id}
      it { expect(response).to be_success}
      it { expect(assigns(:sharing)).to eql basic_sharing1}
    end

    describe "POST 'create' with valid data" do
      before { xhr :post, 'create', sharing: {sharable_id: basic_document1, sharable_type: "Document", group_id: basic_group2}}
      it { expect(response).to be_success}
      it {expect(assigns(:sharing).sharable).to eql basic_document1}
      it {expect(assigns(:sharing)).to be_valid}
    end

    describe "POST 'create' with invalid data" do
      before { xhr :post, 'create', sharing: {sharable_id: basic_document1, sharable_type: "Document", group_id: admin_group1}}
      it { expect(response).to be_unprocessable}
      it {expect(assigns(:sharing).sharable).to eql basic_document1}
      it {expect(assigns(:sharing)).to_not be_valid}
    end

    describe "DELETE 'destroy'" do
      before {
        @sharing_count = Sharing.count
        xhr :delete, :destroy, id: basic_sharing1.id
      }
      it { expect(response).to be_success}
      it {expect(@sharing_count-Sharing.count).to eq(1)}
    end
  end

end
