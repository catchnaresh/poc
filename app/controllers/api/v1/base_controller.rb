class API::V1::BaseController < ApplicationController
  before_action :request_must_be_json
  before_action :resource_class
  before_filter :authenticate_from_token!
  skip_before_filter :verify_authenticity_token
  around_filter :set_time_zone

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { message: e.message,error: 'record not found' }, status: :not_found
  end


  #Set user timezone
  def set_time_zone(&block)
    time_zone = actual_user.try(:time_zone) || 'UTC'
    Time.use_zone(time_zone, &block)
  end

  private

  def user_not_authorized
    render status: :unauthorized,#:forbidden
           json: { success: false, error: 'Access Denied'}
  end

  def authenticate_from_token!
    unless valid_headers?
      render status: 401,  json: {success: false,message: 'Email or Token are missed in headers',
                                  error: "Not authenticated" }
      return
    end
    request.env["devise.skip_trackable"] = true
    resource = @resource_class.search_by_plaintext(:email, email_from_headers).take
    if resource
      resource.auth_tokens.each do |auh_token|
        # Compare token securely due to vulnerable timing attacks
        if Devise.secure_compare(auh_token.token, token_from_headers)
          if auh_token.expired?
            render(status: 401,  json: {success: false, error: "Token expired" })
            return
          else
            sign_in resource, store: false
            resource.touch_token(auh_token) #update last_used timestamp
            return
          end
        end
      end
    end
    render status: 401,  json: {success: false,message: 'Invalid email or token', error: "Not authenticated" }
  end

  def request_must_be_json
    #if request.format != :json
    if request.content_type != 'application/json'
      render status: 406, json: {success: false ,message: 'The request must be json',error: 'Not a valid json request'}
      return
    end
  end

  private
  def valid_headers?
    email_from_headers and token_from_headers
  end

  def resource_class
    @resource_class = model_from_headers.eql?('he') ? HealthExpert : User
  end

  def email_from_headers
    request.headers["X-User-Email"]
  end

  def token_from_headers
    request.headers["X-User-Token"]
  end

  def model_from_headers
    request.headers["X-User-Type"]
  end

end