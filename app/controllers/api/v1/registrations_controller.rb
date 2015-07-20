class API::V1::RegistrationsController < API::BaseController
  #Read: http://stackoverflow.com/questions/10167956/rails-shows-warning-cant-verify-csrf-token-authenticity-from-a-restkit-posts
  skip_before_filter :verify_authenticity_token#, if: Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_from_token!

  #respond_to :json

  def create
    user = User.new(user_params)
    if user.save
      sign_in(user, store: false)
      render status: 200, json: { success: true,info: "Registered",
                        :data => { user: user }}#, auth_token: current_user.authentication_token } }
    else
      render status: :unprocessable_entity,
             json: { success: false,  errors: user.errors.full_messages,  :data => {} }
    end
  end

  def user_params
    params.require(:user).permit(:email, :password,:password_confirmation,:screen_name)
  end


end


