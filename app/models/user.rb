class User
  include Mongoid::Document
  include Mongoid::Timestamps

  include TokenAuthenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  #extra fields
  field :screen_name

  #indexs
  index({ email: 1 }, { unique: true })

  #Validations
  validates :screen_name ,presence: true

  # Associations
  has_many :social_authentications,  dependent: :delete_all

  def apply_oauth(params)
    # In previous omniauth, 'user_info' was used in place of 'raw_info'
    self.email = params[:email] || ''
    self.screen_name = params[:name]
    # Again, saving token is optional. If you haven't created the column in authentications table, this will fail
   # self.social_authentications.build(provider: params[:provider], uid: params[:uid], token: params[:oauth_token],expires_at: Time.at(params[:expires_in].to_i))
  end



end
