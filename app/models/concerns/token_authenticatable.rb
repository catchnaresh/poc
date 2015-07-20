module TokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    has_many :auth_tokens , as: :resoursable
  end

  def generate_auth_token(request)
    auth_token =  auth_tokens.create!(ip_address: request.try(:remote_ip),
                                      user_agent: request.try(:user_agent))
    auth_token.token
  end

  def expire_token(token)
    auth_tokens.where(token: token).first.destroy
  end

  def token_expired?(token)
    auth_tokens.where(token: token).first.expired?
  end

  # remove all unused or old tokens
  def purge_old_tokens
    auth_tokens.desc(:last_used_at).offset(20).destroy_all
  end

  def touch_token(auth_token)
    auth_token.touch(:last_used_at) if auth_token.last_used_at < 30.minutes.ago
  end



  module ClassMethods
     # if any
  end

end