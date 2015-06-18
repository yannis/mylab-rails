require 'rails_helper'

RSpec.describe API::V1::VersionsController, type: :controller do

  context "Not signed in" do
    context "with 3 versions in the database" do

      3.times do |i|
        let!("version_#{i+1}".to_sym){create :version}
      end

      describe "GET 'index'" do
        before { xhr :get, 'index'}
        it { should_not_authorize }
      end

      describe "GET 'show'" do
        before { xhr :get, 'show', id: version_1.id}
        it { should_not_authorize }
      end

      describe "GET 'create'" do
        before { xhr :post, 'create', version: {name: "a new version"}}
        it { should_not_authorize }
      end

      describe "GET 'update'" do
        before { xhr :put, 'update', id: version_1.id, version: {name: "updated name"}}
        it { should_not_authorize }
      end

      describe "GET 'destroy'" do
        before {
          @version_count = Version.count
          xhr :delete, :destroy, id: version_1.id
        }
        it { should_not_authorize }
        it {expect(@version_count-Version.count).to eq(0)}
      end
    end
  end

  context "Signed in" do
    let(:basic_user) { create :user, admin: false }
    let(:admin_user) { create :user, admin: true }
    let(:admin_document) { create :document, user: admin_user}
    let(:basic_document) { create :document, user: basic_user}

    3.times do |i|
      let!("admin_version_#{i+1}".to_sym){create :version, document: admin_document}
    end
    3.times do |i|
      let!("basic_version_#{i+1}".to_sym){create :version, document: basic_document}
    end

    context " as basic" do

      before { sign_in(basic_user) }

      describe "GET 'index'" do
        before { xhr :get, 'index' }
        it { expect(response).to be_success }
        it {expect(assigns(:versions).to_a).to match_array [basic_version_1, basic_version_2, basic_version_3]}
      end

      describe "GET 'show' basic_version_1" do
        before { xhr :get, 'show', id: basic_version_1.id}
        it { expect(response).to be_success }
        it {expect(assigns(:version)).to eql basic_version_1}
      end

      describe "GET 'show' admin_version_1" do
        before { xhr :get, 'show', id: admin_version_1.id}
        it { should_not_authorize }
      end

      describe "POST 'create' with basic_document.id" do
        before { xhr :post, 'create', version: {content_md: "a new version", document_id: basic_document.id}}
        it { expect(response).to be_success}
        it {expect(assigns(:version).content_html).to eql "<p>a new version</p>\n"}
        it {expect(assigns(:version)).to be_valid}
        it {expect(assigns(:version).document).to eql basic_document}
        it {expect(assigns(:version).name).to eql "1"}
      end

      describe "POST 'create' with admin_document.id " do
        before { xhr :post, 'create', version: {content_md: "a new version", document_id: admin_document.id}}
        it { should_not_authorize }
      end

      describe "PUT 'update' basic_version_1" do
        before { xhr :put, :update, id: basic_version_1.id, version: {content_md: "updated content", content_html: "<p>updated content</p>", document_id: basic_document.id}}
        it {expect(response).to be_success}
        it {expect(assigns(:version)).to be_valid}
        it {expect(basic_version_1.reload.content_html).to eql "<p>updated content</p>"}
      end

      describe "PUT 'update' admin_version_1" do
        before { xhr :put, :update, id: admin_version_1.id, version: {content_md: "updated content", content_html: "<p>updated content</p>", document_id: basic_document.id}}
        it { should_not_authorize }
      end

      describe "GET 'destroy' basic_version_1" do
        before {
          @version_count = Version.count
          xhr :delete, :destroy, id: basic_version_1.id
        }
        it {expect(response).to be_success}
        it {expect(@version_count-Version.count).to eq(1)}
      end

      describe "GET 'destroy' admin_version_1" do
        before {
          @version_count = Version.count
          xhr :delete, :destroy, id: admin_version_1.id
        }
        it { should_not_authorize }
      end
    end

    context " as admin" do

      before { sign_in(admin_user) }

      describe "GET 'index'" do
        before { xhr :get, 'index' }
        it { expect(response).to be_success }
        it {expect(assigns(:versions).to_a).to match_array [admin_version_1, admin_version_2, admin_version_3, basic_version_1, basic_version_2, basic_version_3]}
      end

      describe "GET 'show' admin_version_1" do
        before { xhr :get, 'show', id: admin_version_1.id}
        it { expect(response).to be_success }
        it {expect(assigns(:version)).to eql admin_version_1}
      end

      describe "GET 'show' basic_version_1" do
        before { xhr :get, 'show', id: basic_version_1.id}
        it { expect(response).to be_success }
        it {expect(assigns(:version)).to eql basic_version_1}
      end

      describe "POST 'create' with admin_document.id" do
        before { xhr :post, 'create', version: {content_md: "a new version", document_id: admin_document.id}}
        it { expect(response).to be_success}
        it {expect(assigns(:version).content_html).to eql "<p>a new version</p>\n"}
        it {expect(assigns(:version)).to be_valid}
        it {expect(assigns(:version).document).to eql admin_document}
        it {expect(assigns(:version).name).to eql "1"}
      end

      describe "POST 'create' with basic_document.id" do
        before { xhr :post, 'create', version: {content_md: "a new version", document_id: basic_document.id}}
        it { expect(response).to be_success}
        it {expect(assigns(:version).content_html).to eql "<p>a new version</p>\n"}
        it {expect(assigns(:version)).to be_valid}
        it {expect(assigns(:version).document).to eql basic_document}
        it {expect(assigns(:version).name).to eql "1"}
      end

      describe "PUT 'update' admin_version_1" do
        before { xhr :put, :update, id: admin_version_1.id, version: {content_md: "updated content", content_html: "<p>updated content</p>", document_id: admin_document.id}}
        it {expect(response).to be_success}
        it {expect(assigns(:version)).to be_valid}
        it {expect(admin_version_1.reload.content_html).to eql "<p>updated content</p>"}
      end

      describe "PUT 'update' basic_version_1" do
        before { xhr :put, :update, id: basic_version_1.id, version: {content_md: "updated content", content_html: "<p>updated content</p>", document_id: basic_document.id}}
        it {expect(response).to be_success}
        it {expect(assigns(:version)).to be_valid}
        it {expect(basic_version_1.reload.content_html).to eql "<p>updated content</p>"}
      end

      describe "GET 'destroy' admin_version_1" do
        before {
          @version_count = Version.count
          xhr :delete, :destroy, id: admin_version_1.id
        }
        it {expect(response).to be_success}
        it {expect(@version_count-Version.count).to eq(1)}
      end

      describe "GET 'destroy' basic_version_1" do
        before {
          @version_count = Version.count
          xhr :delete, :destroy, id: basic_version_1.id
        }
        it {expect(response).to be_success}
        it {expect(@version_count-Version.count).to eq(1)}
      end
    end
  end
end
