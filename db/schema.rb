# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171111173146) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "branch_managements", force: :cascade do |t|
    t.bigint "branch_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_branch_managements_on_branch_id"
    t.index ["user_id"], name: "index_branch_managements_on_user_id"
  end

  create_table "branches", force: :cascade do |t|
    t.bigint "center_id"
    t.string "name"
    t.string "avatar"
    t.integer "status"
    t.float "cached_avarage_rating"
    t.text "description"
    t.bigint "city_id"
    t.bigint "district_id"
    t.string "address"
    t.string "phone_number"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.float "latitude"
    t.float "longitude"
    t.index ["center_id", "slug"], name: "index_branches_on_center_id_and_slug", unique: true
    t.index ["center_id"], name: "index_branches_on_center_id"
    t.index ["city_id"], name: "index_branches_on_city_id"
    t.index ["district_id"], name: "index_branches_on_district_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "center_managements", force: :cascade do |t|
    t.bigint "center_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_center_managements_on_center_id"
    t.index ["user_id"], name: "index_center_managements_on_user_id"
  end

  create_table "center_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.string "center_name"
    t.string "reference_website"
    t.string "reference_fanpage"
    t.string "phone_number"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_center_requests_on_user_id"
  end

  create_table "centers", force: :cascade do |t|
    t.string "name"
    t.integer "status"
    t.string "avatar"
    t.text "description"
    t.float "cached_average_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "logo"
    t.string "email"
    t.string "phone_number"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_centers_on_category_id"
    t.index ["slug"], name: "index_centers_on_slug", unique: true
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_cities_on_slug", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.string "type"
    t.bigint "user_id"
    t.bigint "review_id"
    t.bigint "branch_id"
    t.text "content"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_comments_on_branch_id", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_comments_on_deleted_at"
    t.index ["review_id"], name: "index_comments_on_review_id", where: "(deleted_at IS NULL)"
    t.index ["user_id"], name: "index_comments_on_user_id", where: "(deleted_at IS NULL)"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["city_id", "slug"], name: "index_districts_on_city_id_and_slug", unique: true
    t.index ["city_id"], name: "index_districts_on_city_id"
  end

  create_table "review_verifications", force: :cascade do |t|
    t.bigint "review_id"
    t.integer "status"
    t.string "email"
    t.string "phone_number"
    t.string "response_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_review_verifications_on_deleted_at"
    t.index ["review_id"], name: "index_review_verifications_on_review_id", where: "(deleted_at IS NULL)"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "branch_id"
    t.string "title"
    t.text "content"
    t.float "summary_rating"
    t.integer "rating_criterion_1"
    t.integer "rating_criterion_2"
    t.integer "rating_criterion_3"
    t.integer "rating_criterion_4"
    t.integer "rating_criterion_5"
    t.integer "status"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vote_points_cached", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.index ["branch_id"], name: "index_reviews_on_branch_id", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_reviews_on_deleted_at"
    t.index ["user_id"], name: "index_reviews_on_user_id", where: "(deleted_at IS NULL)"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "avatar"
    t.string "phone_number"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "review_id"
    t.integer "vote_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_votes_on_deleted_at"
    t.index ["review_id"], name: "index_votes_on_review_id"
    t.index ["user_id", "review_id"], name: "index_votes_on_user_id_and_review_id", unique: true, where: "(deleted_at IS NULL)"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "branch_managements", "branches"
  add_foreign_key "branch_managements", "users"
  add_foreign_key "branches", "centers"
  add_foreign_key "branches", "cities"
  add_foreign_key "branches", "districts"
  add_foreign_key "center_managements", "centers"
  add_foreign_key "center_managements", "users"
  add_foreign_key "center_requests", "users"
  add_foreign_key "centers", "categories"
  add_foreign_key "comments", "branches"
  add_foreign_key "comments", "reviews"
  add_foreign_key "comments", "users"
  add_foreign_key "districts", "cities"
  add_foreign_key "review_verifications", "reviews"
  add_foreign_key "reviews", "branches"
  add_foreign_key "reviews", "users"
  add_foreign_key "votes", "users"
end
