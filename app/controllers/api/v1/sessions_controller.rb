class API::V1::SessionsController < API::BaseController
  skip_before_filter :authenticate_from_token!,only: :create

  #POST /api/v1/login
  def create
    email =   email_from_headers || params[:email]
    password = params[:password]
    @user = @resource_class.where(email: email).first if email.present?
    if @user and @user.valid_password? password
      sign_in @user, store: false
      token = @user.generate_auth_token(request)
      render status: 200,  json: { success: true, user: @user , auth_token: token }
    else
      render status: 422 ,json: { errors: "Invalid email or password" }
    end
  end

  #DELETE /api/v1/logout
  def destroy
    current_user.expire_token(token_from_headers) if current_user
    head 204
  end

end
