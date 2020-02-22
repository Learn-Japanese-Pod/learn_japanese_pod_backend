class PushNotification::Sender
  attr_reader :client 

  def initialize(client: Exponent::Push::Client.new)
    @client = client
  end

  def send(body:, to:)
    Rails.logger.info("SENDING PUSH NOTIFICATION TO: #{to}")

    tickets = client.publish(
      to: to,
      body: body,
    )

    Rails.logger.info("RESPONSE FROM NOTIFICATION SENT TO: #{to}") 
    Rails.logger.info(tickets.to_s)
  end

  def send_batch(batch:)
    client.publish(batch)
  end
end