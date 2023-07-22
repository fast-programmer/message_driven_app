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

ActiveRecord::Schema.define(version: 2023_06_13_050350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "iam_accounts", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "name", null: false
    t.text "slug", null: false
    t.bigint "owner_id", null: false
    t.index ["owner_id"], name: "index_iam_accounts_on_owner_id"
  end

  create_table "iam_users", force: :cascade do |t|
    t.integer "lock_version", default: 0, null: false
    t.text "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "iam_accounts", "iam_users", column: "owner_id"
end
