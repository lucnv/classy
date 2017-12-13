class User < ApplicationRecord
  attr_accessor :login

  has_one :center_management
  has_one :managed_center, through: :center_management, source: :center
  has_many :reviews
  has_many :comments
  has_many :user_comments, class_name: UserComment.name
  has_many :center_comments, class_name: CenterComment.name
  has_many :votes
  has_many :reports
  has_many :received_notifications, class_name: Notification.name, foreign_key: :recipient_id

  PERSONAL_INFORMATION_PARAMS = [:first_name, :last_name, :phone_number]
  ACCOUNT_INFORMATION_PARAMS = [:username, :email, :current_password]
  AVATAR_PARAMS = [:avatar]
  PASSWORD_PARAMS = [:password, :password_confirmation, :current_password]

  validates :first_name, presence: true, length: {maximum: Settings.user.first_name.max_length}
  validates :last_name, presence: true, length: {maximum: Settings.user.last_name.max_length}
  validates :role, presence: true
  validates :username, presence: true, uniqueness: true, on: :update
  validates :avatar, file_size: {less_than_or_equal_to: eval(Settings.validations.user.avatar.max_size)}

  before_create :generate_username
  before_save :downcase_fields

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable, :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  enum role: [:admin, :moderator, :center_manager, :branch_manager, :normal_user]

  mount_uploader :avatar, AvatarUploader

  friendly_findable :username

  def working_center
    if center_manager?
      managed_center
    elsif branch_manager?
      managed_branches.first.try :center
    end
  end

  def branches_under_management
    if center_manager?
      managed_center.branches
    elsif branch_manager?
      managed_branches
    end
  end

  def manage_branch? branch
    branches_under_management.try :include?, branch
  end

  def to_param
    username
  end

  def is_manager?
    center_manager? || branch_manager?
  end

  class << self
    def find_for_database_authentication warden_conditions
      conditions = warden_conditions.dup
      if login = conditions.delete(:login).try(:downcase)
        where(conditions.to_hash).where(username: login).or(User.where email: login).first
      elsif conditions.has_key?(:username) || conditions.has_key?(:email)
        where(conditions.to_hash).first
      end
    end

    def from_omniauth auth
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.avatar = auth.info.image
        user.role = :normal_user
        user.password = Devise.friendly_token[0, 20]
        user.skip_confirmation!
      end
    end
  end

  private
  def generate_username
    self.username = tmp_username = email[/^[^@]+/]
    loop do
      break unless User.exists? username: username
      self.username = tmp_username << SecureRandom.hex(Settings.user.username.random_suffix_length)
    end
  end

  def downcase_fields
     self.username = self.username.try :downcase
  end
end
