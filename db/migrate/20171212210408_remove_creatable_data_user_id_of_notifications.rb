class RemoveCreatableDataUserIdOfNotifications < ActiveRecord::Migration[5.1]
  def change
    remove_column :notifications, :creatable_type
    remove_column :notifications, :creatable_id
    remove_column :notifications, :data
    remove_column :notifications, :user_id
  end
end
