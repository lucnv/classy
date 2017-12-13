class RemoveBranchIdFromComments < ActiveRecord::Migration[5.1]
  def change
    remove_column :comments, :branch_id
  end
end
