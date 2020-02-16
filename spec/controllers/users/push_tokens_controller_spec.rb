require "rails_helper"

describe Users::PushTokensController, type: :controller do
  describe "POST #create" do
    context "when user is created successful" do
      
      it "has a 200 code" do
        post :create, params: { push_token: "ExponentPushToken[123abc123abc123abc123abc]" }

        expect(response.status).to eq(200)
      end
    end

    context "when push_token param is nil" do
      it "has a 400 code with validation errors in the body" do
        post :create, params: { push_notification_token: "ExponentPushToken[123abc123abc123abc123abc]" }
        
        expect(response.status).to eq(400)
        expect(response.body).to eq("{\"push_token\":[\"can't be blank\"]}")
      end 
    end
  end
end