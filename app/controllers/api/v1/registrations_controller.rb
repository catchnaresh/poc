class API::V1::RegistrationsController < API::BaseController
  #Read: http://stackoverflow.com/questions/10167956/rails-shows-warning-cant-verify-csrf-token-authenticity-from-a-restkit-posts
  skip_before_filter :verify_authenticity_token#, if: Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_from_token!

  #respond_to :json

  def create
    user = User.new(user_params)
    if user.save
      sign_in(user, store: false)
      render status: 200, json: { success: true,info: "Registered",  user: user , auth_token: user.generate_auth_token(request) }
    else
      render status: :unprocessable_entity,
             json: { success: false,  errors: user.errors.full_messages.to_sentence,  :data => {} }
    end
  end

  #POST /api/v1/oauth/:provider
  def via_oauth
    # Try to find authentication first
    authentication = SocialAuthentication.where(provider: params['provider'],uid: params['uid']).first
    if authentication
      # Authentication found, sign the user in.
      user = authentication.user
      sign_in user, store: false
      token = user.generate_auth_token(request)
      render status: 200,  json: { success: true, user: user , auth_token: token }
      return
    else
      # Authentication not found, thus a new user.
      # check if user already exists with email
      @user = User.where(email: params[:email]).first if params[:email].present?
      @user = User.new unless @user
      @user.apply_oauth(oauth_params)
      if @user.save(validate: false)
        @user.social_authentications.create(provider: params[:provider], uid: params[:uid],
                                           token: params[:oauth_token],expires_at: Time.at(params[:expires_in].to_i))
        sign_in(@user, store: false)
        render status: 200, json: { success: true,info: "Registered",  user: @user , auth_token: @user.generate_auth_token(request) }
      else
        render status: :unprocessable_entity,
               json: { success: false,  errors: @user.errors.full_messages.to_sentence,  :data => {} }
      end
    end

  end

  private

  def user_params
    params.require(:user).permit(:email, :password,:password_confirmation,:screen_name)
  end

  def oauth_params
    params.permit(:email, :oauth_token,:name,:uid,:expires_in)
  end


end


