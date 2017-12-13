class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :review
  has_one :center, through: :review
  has_many :reports, as: :reportable, dependent: :destroy

  scope :earlier_created, ->{order created_at: :asc}

  acts_as_paranoid

  counter_culture :review

  PARAMS = [:content]

  validates :content, presence: true, length: {minimum: Settings.validations.comment.content.min_length,
    maximum: Settings.validations.comment.content.max_length, allow_blank: true}
  validates :review, :user, presence: true

  delegate :branch_route_params, to: :review, allow_nil: true
end
