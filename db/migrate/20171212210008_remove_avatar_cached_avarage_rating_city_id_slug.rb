class RemoveAvatarCachedAvarageRatingCityIdSlug < ActiveRecord::Migration[5.1]
  def change
    remove_column :branches, :cached_avarage_rating
    remove_column :branches, :avatar
    remove_column :branches, :slug
  end
end
