require 'rails_helper'

describe PushNotification::Sender do
  subject { described_class.new(client: mock_client) }

  let(:mock_client) { instance_double(Exponent::Push::Client, publish: []) }

  describe "#send" do
    let(:to) { "Token[abc123]" }
    let(:body) { "You got a new message" }

    it "calls #publish on client with the given params" do
      subject.send(to: to, body: body)

      expect(mock_client).to have_received(:publish).with({ to: to, body: body, _displayInForeground: true })
    end
  end

  describe "#send_batch" do
    it "calls #publish in the client with array of messages passed" do
      messages = [
        { to: "Token[12345]", body: "This is message one"},
        { to: "Token[67890]", body: "This is message two"}
      ]
      subject.send_batch(batch: messages)

      expect(mock_client).to have_received(:publish).with(messages)
    end
  end
end