class Branch < ApplicationRecord
  ATTRIBUTES = [:name, :avatar, :avatar_cache, :description, :city_id, :district_id,
    :address, :phone_number, :email]

  belongs_to :center
  belongs_to :city
  belongs_to :district
  has_many :reviews
  has_many :comments

  validates :avatar, file_size: {less_than_or_equal_to: eval(Settings.validations.branch.avatar.max_size)}
  validates :name, presence: true, length: {maximum: Settings.validations.branch.name.max_length}
  validates :city_id, :district_id, presence: true
  validates :address, presence: true, length: {maximum: Settings.validations.branch.address.max_length}
  validates :phone_number, presence: true, phone_number_format: true
  validates :email, email_format: true
  validates :description, length: {maximum: Settings.validations.branch.description.max_length}

  after_validation :geocode, if: :require_geocode?

  enum status: [:active, :inactive]

  acts_as_url :name, url_attribute: :slug, scope: :center_id, sync_url: true,
    callback_method: :before_save

  delegate :name, :route_params, to: :center, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true

  geocoded_by :full_address

  mount_uploader :avatar, BusinessAvatarUploader

  friendly_findable :slug

  def full_address
    [address, district_name, city_name].join ", "
  end

  def route_params
    center.route_params.merge branch_slug: slug
  end

  private
  def require_geocode?
    errors.blank? && (address_changed? || city_id_changed? || district_id_changed?)
  end
end
