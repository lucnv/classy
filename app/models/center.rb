class Center < ApplicationRecord
  ATTRIBUTES = [:name, :category_id, :logo, :avatar, :description, :email, :phone_number]
  SORT_OPTIONS = [:recommendation_order, :summary_rating_desc, :minimum_price_asc, :minimum_price_desc]

  belongs_to :center_category, foreign_key: :category_id
  has_many :center_managements
  has_many :branches
  has_many :active_branches, ->{active}, class_name: Branch.name
  has_many :cities, ->{distinct}, through: :branches
  has_many :active_branches_cities, through: :active_branches,
    source: :city
  has_many :reviews
  has_many :courses
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :notifications, as: :notifiable
  has_many :managers, through: :center_managements, source: :user

  validates :logo, file_size: {less_than_or_equal_to: eval(Settings.validations.center.logo.max_size)}
  validates :avatar, file_size: {less_than_or_equal_to: eval(Settings.validations.center.avatar.max_size)}
  validates :name, presence: true, length: {maximum: Settings.validations.center.name.max_length}
  validates :category_id, presence: true
  validates :description, length: {maximum: Settings.validations.center.description.max_length}
  validates :email, email_format: true, length: {maximum: Settings.validations.center.email.max_length}
  validates :phone_number, phone_number_format: true

  scope :recommendation_order, ->{}
  scope :summary_rating_desc, ->{order "summary_rating_cached DESC NULLS LAST"}
  scope :minimum_price_asc, ->{order "min_course_price ASC NULLS LAST"}
  scope :minimum_price_desc, ->{order "min_course_price DESC NULLS LAST"}
  scope :order_by, ->(order_option){public_send order_option}

  enum status: [:active, :inactive]

  acts_as_url :name, url_attribute: :slug, sync_url: true, callback_method: :before_save

  mount_uploader :avatar, BusinessAvatarUploader
  mount_uploader :logo, AvatarUploader

  delegate :name, to: :center_category, prefix: true, allow_nil: true

  friendly_findable :slug

  ransack_alias :city_key_name, :active_branches_city_key_name
  ransack_alias :district_key_name, :active_branches_district_key_name

  def route_params
    {center_slug: slug}
  end

  def update_summary_rating_cached
    center_rating = reviews.verified.select("SUM(summary_rating) / COUNT(*) AS rating")[0].rating
    update_column :summary_rating_cached, center_rating
  end

  class << self
    def ransackable_scopes auth_object = nil
      %i(order_by)
    end
  end
end
