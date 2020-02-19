class Users::PushTokensController < ApplicationController
  before_action :authenticate!, only: [:create]

  def create
    user = User::CreateWithPushToken
      .new(push_token)
      .create

    if user.valid?
      render json: { body: "success" }, status: 200
    else
      render json: { errors: user.errors }, status: 400
    end
  end

  private

  def push_token
    params.permit(:push_token)[:push_token]
  end

  def auth_token
    pattern = /^Token /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def authenticate!
    if auth_token.blank?
      render json: { message: "Authentication Token not present" }, status: 401
      return 
    end

    unless mobile_app_tokens.any? { |token| token == auth_token }
      render json: { message: "Invalid Authentication Token provided" }, status: 401
      return
    end 
  end

  def mobile_app_tokens
    [ENV["MOBILE_APP_TOKEN"], ENV["BACKUP_MOBILE_APP_TOKEN"]].reject(&:blank?)
  end
end