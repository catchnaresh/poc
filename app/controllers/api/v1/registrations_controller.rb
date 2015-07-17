class API::V1::RegistrationsController < Devise::RegistrationsController
  #Read: http://stackoverflow.com/questions/10167956/rails-shows-warning-cant-verify-csrf-token-authenticity-from-a-restkit-posts
  skip_before_filter :verify_authenticity_token#, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :doorkeeper_authorize!
  #respond_to :json

  def create
    build_resource
    if resource.save
      sign_in(resource, store: false)
      render status: 200, json: { success: true,info: "Registered",
                        :data => { user: resource,
                                   auth_token: current_user.authentication_token } }
    else
      render status: :unprocessable_entity,
             json: { success: false,  errors: resource.errors.full_messages,  :data => {} }
    end
  end

end

