class API::BaseController < ApplicationController

  before_action :doorkeeper_authorize!
 # before_action :request_must_be_json
  before_action :resource_class
  before_filter :authenticate_from_token!
  skip_before_filter :verify_authenticity_token
  around_filter :set_time_zone

  respond_to :json

  # rescue_from ActiveRecord::RecordNotFound do |e|
  #   render json: { message: e.message,error: 'record not found' }, status: :not_found
  # end


  #Set user timezone
  def set_time_zone(&block)
    time_zone = current_user.try(:time_zone) || 'UTC'
    Time.use_zone(time_zone, &block)
  end

  private

  def user_not_authorized
    render status: :unauthorized,#:forbidden
           json: { success: false, errors: 'Access Denied'}
  end

  def authenticate_from_token!
    unless valid_headers?
      render status: 401,  json: {success: false,errors: 'Email and Token are missed in headers',
                                  error: "Not authenticated" }
      return
    end
    request.env["devise.skip_trackable"] = true
    resource = @resource_class.where(email: email_from_headers).first
    if resource
      resource.auth_tokens.each do |auh_token|
        # Compare token securely due to vulnerable timing attacks
        if Devise.secure_compare(auh_token.token, token_from_headers)
          if auh_token.expired?
            render(status: 401,  json: {success: false, errors: "Token expired" })
            return
          else
            sign_in resource, store: false
            resource.touch_token(auh_token) #update last_used timestamp
            return
          end
        end
      end
    end
    render status: 401,  json: {success: false,errors: 'Invalid email or token', error: "Not authenticated" }
  end

  def request_must_be_json
    #if request.format != :json
    if request.content_type != 'application/json'
      render status: 406, json: {success: false ,errors: 'The request must be json',error: 'Not a valid json request'}
      return
    end
  end

  private
  def valid_headers?
    email_from_headers and token_from_headers
  end

  def resource_class
    @resource_class =  User
  end

  def email_from_headers
    request.headers["X-User-Email"] || params[:email]
  end

  def token_from_headers
    request.headers["X-User-Token"] || params[:auth_token]
  end


end