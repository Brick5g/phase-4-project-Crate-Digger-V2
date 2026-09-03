# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_03_142201) do
  create_table "artists", force: :cascade do |t|
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.string "hometown"
    t.string "musicbrainz_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_artists_on_name", unique: true
  end

  create_table "collection_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes", null: false
    t.integer "record_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["record_id"], name: "index_collection_entries_on_record_id"
    t.index ["user_id", "record_id"], name: "index_collection_entries_on_user_id_and_record_id", unique: true
    t.index ["user_id"], name: "index_collection_entries_on_user_id"
  end

  create_table "genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "record_genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "genre_id", null: false
    t.text "notes", null: false
    t.boolean "primary_genre", default: false, null: false
    t.integer "record_id", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_record_genres_on_genre_id"
    t.index ["record_id", "genre_id"], name: "index_record_genres_on_record_id_and_genre_id", unique: true
    t.index ["record_id"], name: "index_record_genres_on_record_id"
  end

  create_table "records", force: :cascade do |t|
    t.integer "artist_id", null: false
    t.string "artwork_url"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "musicbrainz_id"
    t.date "release_date"
    t.string "release_type"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_records_on_artist_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.integer "record_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["record_id"], name: "index_reviews_on_record_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "collection_entries", "records"
  add_foreign_key "collection_entries", "users"
  add_foreign_key "record_genres", "genres"
  add_foreign_key "record_genres", "records"
  add_foreign_key "records", "artists"
  add_foreign_key "reviews", "records"
  add_foreign_key "reviews", "users"
end
