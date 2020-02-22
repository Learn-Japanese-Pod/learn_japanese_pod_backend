class PushNotification::Sender
  attr_reader :client 

  def initialize(client: Exponent::Push::Client.new)
    @client = client
  end

  def send(title:, body:, to:)
    client.publish(
      to: to,
      title: title,
      body: body,
    )
  end

  def send_batch(batch:)
    client.publish(batch)
  end
end