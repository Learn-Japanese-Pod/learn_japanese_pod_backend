require "rails_helper"

describe PushNotifications::SendController, type: :controller do
  let(:mobile_app_token) { SecureRandom.hex(64) }
  let(:backup_mobile_app_token) { SecureRandom.hex(64) }

  before do
    allow(ENV).to receive(:[]).with("MOBILE_APP_TOKEN").and_return(mobile_app_token)
    allow(ENV).to receive(:[]).with("BACKUP_MOBILE_APP_TOKEN").and_return(nil)
  end

  describe "POST #create" do
    let(:push_token) { "ExponentPushToken[123abc123abc123abc123abc]" }

    context "when User is not registed" do
      it "Raises not found error" do
        @request.headers["Authorization"] = "Token #{mobile_app_token}"

        expect(PushNotification::Sender).not_to receive(:send)

        post :create, params: { push_token: push_token, title: "Title", body: "Body" }
       
        expect(response.status).to eq(404)
      end
    end

    context "when User is registered" do
      it "Sends a push notification to the passed token" do
        User.create!(push_token: push_token)

        @request.headers["Authorization"] = "Token #{mobile_app_token}"

        expect_any_instance_of(PushNotification::Sender)
          .to receive(:send)
          .with(to: push_token, title: "Title", body: "Body")
          .once

        post :create, params: { push_token: push_token, title: "Title", body: "Body" }

        expect(response.status).to eq(200)
      end
    end
  end
end