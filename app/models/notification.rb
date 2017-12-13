class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :recipient, class_name: User.name, foreign_key: :recipient_id

  after_create :relay_notification

  enum action: [:new_review_verification, :review_rejected, :review_verified,
    :review_voted_up, :review_voted_down]

  private
  def relay_notification
    NotificationRelayJob.perform_later self
  end
end
