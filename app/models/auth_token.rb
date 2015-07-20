class AuthToken
  include Mongoid::Document
  include Mongoid::Timestamps

  #Fields
  field :token
  field :last_used_at ,type: DateTime
  field :expires_at ,type: DateTime
  field :ip_address
  field :user_agent

  #indexes
  index({ token: 1 }, { unique: true })

  # Associations --------------------------------
  belongs_to :resoursable, polymorphic: true

  # Validations ----------------------------------
  validates :resoursable,presence: true

  # Callbacks ------------------------------------
  before_create :generate_token
  before_create :set_expire_and_last_used



  def expired?
    self.expires_at < Time.now
  end

  private

  def generate_token
    secure_token = Devise.friendly_token
    loop do
      break if self.class.where(token: secure_token,resoursable_id: resoursable_id,resoursable_type: resoursable_type).blank?
      secure_token = Devise.friendly_token
    end
    self.token ||= secure_token
  end

  # token will expires in 60 days from generated time
  def set_expire_and_last_used
    self.last_used_at = Time.now
    self.expires_at = 60.days.from_now
  end

end
