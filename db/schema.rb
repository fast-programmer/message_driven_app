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

ActiveRecord::Schema.define(version: 2023_07_19_102022) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "iam_accounts", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "name", null: false
    t.text "slug", null: false
    t.bigint "owner_id", null: false
    t.index ["owner_id"], name: "index_iam_accounts_on_owner_id"
  end

  create_table "iam_user_accounts", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_iam_user_accounts_on_account_id"
    t.index ["user_id"], name: "index_iam_user_accounts_on_user_id"
  end

  create_table "iam_users", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "messaging_handlers", force: :cascade do |t|
    t.bigint "queue_id", null: false
    t.text "slug", null: false
    t.text "name", null: false
    t.text "class_name", null: false
    t.boolean "enabled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["queue_id", "slug"], name: "index_messaging_handlers_on_queue_id_and_slug", unique: true
  end

  create_table "messaging_job_attempts", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.integer "index", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at", null: false
    t.boolean "successful", null: false
    t.jsonb "return_value"
    t.text "error_class_name"
    t.text "error_message"
    t.text "error_backtrace", array: true
    t.index ["job_id"], name: "index_messaging_job_attempts_on_job_id"
  end

  create_table "messaging_jobs", force: :cascade do |t|
    t.bigint "queue_id", null: false
    t.bigint "message_id", null: false
    t.text "handler_class_name", null: false
    t.text "status", null: false
    t.bigint "priority", null: false
    t.datetime "scheduled_for"
    t.integer "attempts_count", null: false
    t.integer "attempts_max", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_messaging_jobs_on_status"
  end

  create_table "messaging_messages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.bigint "queue_id", null: false
    t.text "type", null: false
    t.text "body_class_name", null: false
    t.jsonb "body_json", null: false
    t.text "messageable_type", null: false
    t.bigint "messageable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messaging_queues", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "name", null: false
    t.text "slug", null: false
    t.index ["slug"], name: "index_messaging_queues_on_slug", unique: true
  end

  create_table "messaging_tests", force: :cascade do |t|
  end

  add_foreign_key "iam_accounts", "iam_users", column: "owner_id"
  add_foreign_key "iam_user_accounts", "iam_accounts", column: "account_id"
  add_foreign_key "iam_user_accounts", "iam_users", column: "user_id"
  add_foreign_key "messaging_handlers", "messaging_queues", column: "queue_id"
  add_foreign_key "messaging_job_attempts", "messaging_jobs", column: "job_id"
  add_foreign_key "messaging_jobs", "messaging_messages", column: "message_id"
  add_foreign_key "messaging_jobs", "messaging_queues", column: "queue_id"
  add_foreign_key "messaging_messages", "messaging_queues", column: "queue_id"
end
