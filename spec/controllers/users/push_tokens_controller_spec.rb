require "rails_helper"

describe Users::PushTokensController, type: :controller do
  let(:mobile_app_token) { SecureRandom.hex(64) }
  let(:backup_mobile_app_token) { SecureRandom.hex(64) }

  before do
    allow(ENV).to receive(:[]).with("MOBILE_APP_TOKEN").and_return(mobile_app_token)
    allow(ENV).to receive(:[]).with("BACKUP_MOBILE_APP_TOKEN").and_return(nil)
  end

  describe "POST #create" do
    context "when BACKUP_MOBILE_APP_TOKEN is nil" do
      context "and Authorization Token is empty" do
        it "returns a unauthorised error" do
          post :create, params: { push_token: "ExponentPushToken[123abc123abc123abc123abc]" }
          
          expect(response.status).to eq(401)
        end
      end

      context "and Authorization Token is invalid" do
        it "returns a unauthorised error" do
          @request.headers["Authorization"] = "Token notvalidtoken"
          post :create, params: { push_token: "ExponentPushToken[123abc123abc123abc123abc]" }
          
          expect(response.status).to eq(401)
        end
      end

      context "and correct Authorization Token is passed" do
        it "has a 200 code" do
          @request.headers["Authorization"] = "Token #{mobile_app_token}"
          post :create, params: { push_token: "ExponentPushToken[123abc123abc123abc123abc]" }

          expect(response.status).to eq(200)
        end
      end
    end

    context "when BACKUP_MOBILE_APP_TOKEN is not nil" do
      before do
        allow(ENV).to receive(:[]).with("BACKUP_MOBILE_APP_TOKEN").and_return(backup_mobile_app_token)
      end

      context "and correct Authorization Token is passed" do
        it "has a 200 code" do
          @request.headers["Authorization"] = "Token #{mobile_app_token}"
          post :create, params: { push_token: "ExponentPushToken[123abc123abc123abc123abc]" }

          expect(response.status).to eq(200)
        end
      end
      
      context "and Authorization Token is == BACKUP_MOBILE_APP_TOKEN" do
        it "has a 200 code" do
          @request.headers["Authorization"] = "Token #{backup_mobile_app_token}"
          post :create, params: { push_token: "ExponentPushToken[123abc123abc123abc123abc]" }

          expect(response.status).to eq(200)
        end
      end
    end

    context "when push_token param is nil" do
      it "has a 400 code with validation errors in the body" do
        @request.headers["Authorization"] = "Token #{mobile_app_token}"
        post :create, params: { push_notification_token: "ExponentPushToken[123abc123abc123abc123abc]" }
        
        expect(response.status).to eq(400)
        expect(response.body).to eq("{\"errors\":{\"push_token\":[\"can't be blank\"]}}")
      end 
    end
  end

  describe "DELETE #destroy" do
    let(:push_token) { "ExponentPushToken[123abc123abc123abc123abc]" }

    context "when User is not registed" do
      it "Raises not found error" do
        @request.headers["Authorization"] = "Token #{mobile_app_token}"
        delete :destroy, params: { id: push_token }
       
        expect(response.status).to eq(404)
      end
    end

    context "when User is registered" do
      it "Deletes the user with passed token" do
        User.create!(push_token: push_token)

        @request.headers["Authorization"] = "Token #{mobile_app_token}"
        expect {
          delete :destroy, params: { id: push_token }
        }.to change(User, :count).from(1).to(0)

        expect(response.status).to eq(200)
      end
    end
  end
end