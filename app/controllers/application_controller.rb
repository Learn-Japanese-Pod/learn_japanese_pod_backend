class ApplicationController < ActionController::API
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
      render json: { message: "Invalid Authentication Token provided: #{auth_token}" }, status: 401
      return
    end 
  end

  def mobile_app_tokens
    [ENV["MOBILE_APP_TOKEN"], ENV["BACKUP_MOBILE_APP_TOKEN"]].reject(&:blank?)
  end
end
