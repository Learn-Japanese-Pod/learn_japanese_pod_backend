class PushNotifications::SendController < ApplicationController
  before_action :authenticate!

  def create
    user = User.find_by!(push_token: permitted_params[:push_token])

    PushNotification::Sender.new.send(
      to: user.push_token,
      body: permitted_params[:body],
    )
    
    render json: { message: "success" }, status: 200
  rescue ActiveRecord::RecordNotFound, TypeError
    render json: { message: "User with passed PushToken not registered" }, status: 404
  end

  private

  def permitted_params
    params.permit(:push_token, :body)
  end
end