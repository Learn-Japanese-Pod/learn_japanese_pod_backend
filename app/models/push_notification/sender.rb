class PushNotification::Sender
  attr_reader :client 

  def initialize(client: Exponent::Push::Client.new)
    @client = client
  end

  def send(title:, body:, to:)
    Rails.logger.info("SENDING PUSH NOTIFICATION TO: #{to}")

    tickets = client.publish(
      to: to,
      title: title,
      body: body,
    )

    Rails.logger.info("RESPONSE FROM NOTIFICATION SENT TO: #{to}") 
    Rails.logger.info(tickets.to_s)
  end

  def send_batch(batch:)
    client.publish(batch)
  end
end