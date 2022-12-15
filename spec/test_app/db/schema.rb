# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_10_145530) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "document_type"
    t.binary "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_bookmarks_on_document_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "searches", force: :cascade do |t|
    t.binary "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "user_group_authentications", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
  end

  create_table "user_group_groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_locked", default: false
    t.boolean "reader_group", default: false
    t.index ["name"], name: "index_user_group_groups_on_name", unique: true
  end

  create_table "user_group_memberships", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "approved_by"
    t.text "request_form"
    t.index ["group_id", "user_id"], name: "index_user_group_memberships_on_group_id_and_user_id", unique: true
  end

  create_table "user_group_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "second_name"
    t.string "locale"
    t.boolean "guest", default: false
    t.integer "view_level", default: 0
    t.string "about_me", default: ""
    t.datetime "token_creation_date"
    t.string "image_link"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["authentication_token"], name: "index_user_group_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_user_group_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_user_group_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_user_group_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", limit: 8, null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
