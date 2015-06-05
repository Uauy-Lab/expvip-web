# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150531204102) do

  create_table "experiment_groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "experiment_groups_experiments", id: false, force: :cascade do |t|
    t.integer "experiment_group_id", limit: 4, null: false
    t.integer "experiment_id",       limit: 4, null: false
  end

  add_index "experiment_groups_experiments", ["experiment_group_id"], name: "index_experiment_groups_experiments_on_experiment_group_id", using: :btree
  add_index "experiment_groups_experiments", ["experiment_id"], name: "index_experiment_groups_experiments_on_experiment_id", using: :btree

  create_table "experiments", force: :cascade do |t|
    t.integer  "variety_id", limit: 4
    t.integer  "tissue_id",  limit: 4
    t.string   "age",        limit: 255
    t.string   "stress",     limit: 255
    t.string   "accession",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "experiments", ["accession"], name: "index_experiments_on_accession", using: :btree
  add_index "experiments", ["tissue_id"], name: "index_experiments_on_tissue_id", using: :btree
  add_index "experiments", ["variety_id"], name: "index_experiments_on_variety_id", using: :btree

  create_table "species", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "scientific_name", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "studies", force: :cascade do |t|
    t.string   "accession",  limit: 255
    t.integer  "species_id", limit: 4
    t.string   "title",      limit: 255
    t.string   "manuscript", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "studies", ["accession"], name: "index_studies_on_accession", using: :btree
  add_index "studies", ["species_id"], name: "index_studies_on_species_id", using: :btree
  add_index "studies", ["title"], name: "index_studies_on_title", using: :btree

  create_table "tissues", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "varieties", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "url",         limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_foreign_key "experiments", "tissues"
  add_foreign_key "experiments", "varieties"
  add_foreign_key "studies", "species"
end
