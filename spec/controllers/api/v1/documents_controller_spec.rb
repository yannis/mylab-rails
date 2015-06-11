require 'rails_helper'

RSpec.describe API::V1::DocumentsController, type: :controller do

  context "Not signed in" do
    context "with 3 documents in the database" do

      3.times do |i|
        let!("document_#{i+1}".to_sym){create :document}
      end

      describe "GET 'index'" do
        before { xhr :get, 'index'}
        it { should_not_authorize }
      end

      describe "GET 'show'" do
        before { xhr :get, 'show', id: document_1.id}
        it { should_not_authorize }
      end

      describe "GET 'create'" do
        before { xhr :post, 'create', document: {name: "a new document"}}
        it { should_not_authorize }
      end

      describe "GET 'update'" do
        before { xhr :put, 'update', id: document_1.id, document: {name: "updated name"}}
        it { should_not_authorize }
      end

      describe "GET 'destroy'" do
        before {
          @document_count = Document.count
          xhr :delete, :destroy, id: document_1.id
        }
        it { should_not_authorize }
        it {expect(@document_count-Document.count).to eq(0)}
      end
    end
  end

  context "Signed in" do

    let(:user) { create :user }
    before { sign_in(user) }

    context "with 3 documents in the database" do

      3.times do |i|
        let!("document_#{i+1}".to_sym){create :document, user: user}
      end

      describe "GET 'index'" do
        before { xhr :get, 'index' }
        it { expect(response).to be_success }
        it {expect(assigns(:documents).to_a).to match_array [document_1, document_2, document_3]}
      end

      describe "GET 'show'" do
        before { xhr :get, 'show', id: document_1.id}
        it { expect(response).to be_success }
        it {expect(assigns(:document)).to eql document_1}
      end

      describe "GET 'create'" do
        before { xhr :post, 'create', document: {name: "a new document"}}
        it { expect(response).to be_success}
        it {expect(assigns(:document).name).to eql "a new document"}
        it {expect(assigns(:document)).to be_valid}
        it {expect(assigns(:document).user).to eql user}
      end

      describe "GET 'update'" do
        before { xhr :put, :update, id: document_1.id, document: {name: "updated name"}}
        it {expect(response).to be_success}
        it {expect(document_1.reload.name).to eql "updated name"}
      end

      describe "GET 'destroy'" do
        before {
          @document_count = Document.count
          xhr :delete, :destroy, id: document_1.id
        }
        it {expect(response).to be_success}
        it {expect(@document_count-Document.count).to eq(1)}
      end
    end
  end
end
