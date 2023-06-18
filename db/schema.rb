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

ActiveRecord::Schema.define(version: 2023_06_16_193741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "name", null: false
    t.text "slug", null: false
    t.bigint "owner_id", null: false
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
  end

  create_table "messaging_messages", force: :cascade do |t|
    t.bigint "queue_id", null: false
    t.bigint "account_id"
    t.bigint "user_id", null: false
    t.text "name", null: false
    t.text "type", null: false
    t.jsonb "body"
    t.text "status", null: false
    t.text "messageable_type", null: false
    t.bigint "messageable_id", null: false
    t.datetime "queued_until"
    t.integer "retry_count", default: 0, null: false
    t.integer "retry_limit", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "error_class_name"
    t.text "error_message"
    t.text "error_backtrace", array: true
    t.index ["messageable_type", "messageable_id"], name: "index_messaging_messages_on_messageable_type_and_messageable_id"
    t.index ["status", "created_at"], name: "index_messaging_messages_on_status_and_created_at"
    t.index ["status"], name: "index_messaging_messages_on_status"
    t.index ["type"], name: "index_messaging_messages_on_type"
  end

  create_table "messaging_queues", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "name", null: false
    t.index ["name"], name: "index_messaging_queues_on_name", unique: true
  end

  create_table "user_accounts", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_user_accounts_on_account_id"
    t.index ["user_id"], name: "index_user_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "accounts", "users", column: "owner_id"
  add_foreign_key "messaging_messages", "accounts"
  add_foreign_key "messaging_messages", "messaging_queues", column: "queue_id"
  add_foreign_key "messaging_messages", "users"
  add_foreign_key "user_accounts", "accounts"
  add_foreign_key "user_accounts", "users"
end
