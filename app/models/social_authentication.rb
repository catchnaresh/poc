class SocialAuthentication
  include Mongoid::Document
  include Mongoid::Timestamps

  #Fields
  field :provider
  field :token
  field :uid
  field :expires_at ,type: DateTime

  #indexes
  index({ provider: 1 ,uid: 1})

  # Associations --------------------------------
  belongs_to :user

  #Validations
  validates_uniqueness_of :provider, scope: :uid

end
