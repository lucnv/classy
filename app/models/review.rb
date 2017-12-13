class Review < ApplicationRecord
  SORT_OPTIONS = [:recent_created, :vote_points_desc]
  ATTRIBUTES_TO_PERSIST_CONTENT = [:branch_id, :rating_criterion_1, :rating_criterion_2,
    :rating_criterion_3, :rating_criterion_4, :rating_criterion_5, :title, :content]
  ATTRIBUTES_TO_PERSIST_VERIFICATION = [:email_verifiable, :phone_number_verifiable]
  PARAMS_VERIFY = [:status]
  ATTRIBUTES_TO_PERSIST_FULL = ATTRIBUTES_TO_PERSIST_CONTENT + ATTRIBUTES_TO_PERSIST_VERIFICATION

  belongs_to :center
  belongs_to :user
  belongs_to :branch, optional: true
  has_many :comments, dependent: :destroy
  has_many :votes
  has_many :reports, as: :reportable, dependent: :destroy

  before_save :calculate_summary_rating, if: :rating_criteria_changed?
  after_save :update_center_summary_rating_cached, if: :influence_center_rating?
  after_save :notify_new_review_verification, if: :new_verification_request?

  validates :title, presence: true, length: {minimum: Settings.validations.review.title.min_length,
    maximum: Settings.validations.review.title.max_length, allow_blank: true}
  validates :content, presence: true, length: {minimum: Settings.validations.review.content.min_length,
    maximum: Settings.validations.review.content.max_length, allow_blank: true}
  validates :rating_criterion_1, :rating_criterion_2, :rating_criterion_3,
    :rating_criterion_4, :rating_criterion_5, presence: true,
    numericality: {only_integer: true, allow_blank: true}
  validates :email_verifiable, presence: true, email_format: true,
    length: {maximum: Settings.validations.review.email.max_length}
  validates :phone_number_verifiable, presence: true, phone_number_format: true

  scope :recent_created, ->{order created_at: :desc}
  scope :vote_points_desc, ->{order vote_points_cached: :desc}
  scope :with_voted_type_by_user, ->user do
    joins("LEFT OUTER JOIN #{Vote.table_name}
      ON #{Review.table_name}.id = #{Vote.table_name}.review_id AND #{Vote.table_name}.user_id = #{user.id}")
      .select("#{Review.table_name}.*, #{Vote.table_name}.vote_type AS voted_type")
  end
  scope :order_by, ->(sort_scope){public_send sort_scope}

  enum status: [:unverified, :verified, :rejected]

  acts_as_paranoid

  delegate :name, :route_params, to: :branch, prefix: true, allow_nil: true

  def update_vote_points_cached
    update_columns vote_points_cached: Vote.points_of_review(self)
  end

  class << self
    def ransackable_scopes auth_object = nil
      %i(order_by)
    end
  end

  private
  def rating_criteria_changed?
    Settings.review.criteria.map(&:attr_name).any? do |criterion|
      public_send "#{criterion}_changed?"
    end
  end

  def calculate_summary_rating
    self.summary_rating = Settings.review.criteria.inject(0) do |summary, criterion|
      summary + public_send(criterion.attr_name) * criterion.ratio
    end / 100.to_f
  end

  def influence_center_rating?
    verified? && (saved_change_to_status? || saved_change_to_summary_rating?)
  end

  def update_center_summary_rating_cached
    center.update_summary_rating_cached
  end

  def new_verification_request?
    unverified? && (saved_change_to_email_verifiable? || saved_change_to_phone_number_verifiable?)
  end

  def notify_new_review_verification
    NotifyNewReviewVerificationJob.perform_later self
  end
end
