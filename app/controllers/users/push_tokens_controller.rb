class Users::PushTokensController < ApplicationController
  before_action :authenticate!

  def create
    user = User::CreateWithPushToken
      .new(push_token)
      .create

    if user.valid?
      render json: { message: "success" }, status: 200
    else
      render json: { errors: user.errors }, status: 400
    end
  end

  def destroy
    user = User.find_by!(push_token: id)

    user.destroy

    render json: { body: "success" }, status: 200
  rescue ActiveRecord::RecordNotFound
    render json: { message: "User with passed PushToken not registered" }, status: 404
  end

  private

  def push_token
    params.permit(:push_token)[:push_token]
  end

  def id
    params.permit(:id)[:id]
  end
end