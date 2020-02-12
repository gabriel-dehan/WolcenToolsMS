class ApplicationController < ActionController::API
  class AuthenticationError < StandardError; end
  before_action :authenticate!

  # def current_user 
  #   @auth_user
  # end

  private
  def authenticate!
    if params[:api_key]
      # @auth_user = ...
      raise AuthenticationError.new("Invalid auth token") unless params[:api_key] == ENV['API_KEY']
    else
      raise AuthenticationError.new("Need to provide auth token")
    end
  end
end
