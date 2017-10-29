class Review < ApplicationRecord
  SORTING_OPTIONS = [{name: :newest, value: "created_at asc"},
    {name: :most_voting, value: "vote_points_cached desc"}
  ]

  belongs_to :user
  belongs_to :branch
  has_many :comments, dependent: :destroy
  has_many :votes
  has_many :review_verifications, dependent: :destroy

  scope :recent_created, ->{order created_at: :desc}
  scope :with_voted_type_by_user, ->user do
    joins("LEFT OUTER JOIN #{Vote.table_name}
      ON #{Review.table_name}.id = #{Vote.table_name}.review_id AND #{Vote.table_name}.user_id = #{user.id}")
      .select("#{Review.table_name}.*, #{Vote.table_name}.vote_type AS voted_type")
  end
  scope :most_voting, ->{order vote_points_cached: :desc}

  enum status: [:unverified, :verified]

  acts_as_paranoid

  def update_vote_points_cached
    update_columns vote_points_cached: Vote.points_of_review(self)
  end

  class << self
    # Add sorting scopes to Ransack for approval_rate computed column
    #
    def ransackable_scopes(auth_object = nil)
      [:recent_created, :most_voting]
    end
  end
end
