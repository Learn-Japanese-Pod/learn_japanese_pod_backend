require "rails_helper"

describe User::CreateWithPushToken, type: :model do
  let(:push_token) { "ExponentPushToken[123abc123abc123abc123abc]" }
  subject(:service) { described_class.new(push_token) }

  describe "#create" do
    context "when user already exists" do
      it "does not create a new user" do
        User.create(push_token: push_token)

        expect { subject.create }
          .not_to change(User, :count)
      end
    end

    context "when user does not exist" do
      it "creates a new user" do
        expect { subject.create }
          .to change(User, :count)
          .by(1)
      end

      context "and push_token is blank" do
        let(:push_token) { "" }

        it "does not create a new user" do
          expect { subject.create }
            .not_to change(User, :count)
        end

        it "returns invalid user" do
          user = subject.create

          expect(user.valid?).to eq(false)
        end
      end
    end
  end
end