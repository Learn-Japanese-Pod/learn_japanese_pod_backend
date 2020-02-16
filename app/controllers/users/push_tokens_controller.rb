class Users::PushTokensController < ApplicationController
  def create
    user = User::CreateWithPushToken
      .new(push_token)
      .create

    if user.valid?
      render json: { body: "success" }, status: 200
    else
      render json: user.errors, status: 400
    end
  end

  def push_token
    params.permit(:push_token)[:push_token]
  end
end