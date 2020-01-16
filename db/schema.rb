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

ActiveRecord::Schema.define(version: 20200116080254) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "overwork_time"
    t.string "overwork_note"
    t.boolean "overwork_tomorrow"
    t.integer "overwork_superior_id"
    t.integer "overwork_enum", default: 1
    t.boolean "overwork_request_change"
    t.integer "month_superior_id"
    t.integer "monthly_enum", default: 1
    t.boolean "monthly_request_change"
    t.integer "change_attendance_id"
    t.datetime "edit_started_at"
    t.datetime "edit_finished_at"
    t.integer "change_at_enum", default: 1
    t.boolean "change_at_change"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2020-01-07 23:00:00"
    t.datetime "work_time", default: "2020-01-07 22:30:00"
    t.boolean "superior", default: false
    t.datetime "designated_work_start_time", default: "2020-01-08 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-01-08 09:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
