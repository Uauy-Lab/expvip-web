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

ActiveRecord::Schema.define(version: 20150917220826) do

  create_table "ExperimentGroups_Factors", id: false, force: :cascade do |t|
    t.integer "experiment_group_id", limit: 4, null: false
    t.integer "factor_id",           limit: 4, null: false
  end

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
    t.string   "accession",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "study_id",   limit: 4
  end

  add_index "experiments", ["accession"], name: "index_experiments_on_accession", using: :btree
  add_index "experiments", ["study_id"], name: "index_experiments_on_study_id", using: :btree

  create_table "expression_values", force: :cascade do |t|
    t.integer  "experiment_id",      limit: 4
    t.integer  "gene_id",            limit: 4
    t.integer  "meta_experiment_id", limit: 4
    t.integer  "type_of_value_id",   limit: 4
    t.float    "value",              limit: 24
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "expression_values", ["experiment_id"], name: "index_expression_values_on_experiment_id", using: :btree
  add_index "expression_values", ["gene_id"], name: "index_expression_values_on_gene_id", using: :btree
  add_index "expression_values", ["meta_experiment_id"], name: "index_expression_values_on_meta_experiment_id", using: :btree
  add_index "expression_values", ["type_of_value_id"], name: "index_expression_values_on_type_of_value_id", using: :btree

  create_table "factors", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.integer  "order",       limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "factor",      limit: 255
  end

  add_index "factors", ["factor"], name: "index_factors_on_factor", using: :btree

  create_table "gene_sets", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "genes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "cdna",        limit: 255
    t.string   "possition",   limit: 255
    t.string   "gene",        limit: 255
    t.string   "transcript",  limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "gene_set_id", limit: 4
    t.text     "description", limit: 65535
  end

  add_index "genes", ["gene_set_id"], name: "index_genes_on_gene_set_id", using: :btree
  add_index "genes", ["name"], name: "index_genes_on_name", using: :btree

  create_table "meta_experiments", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.integer  "gene_set_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "meta_experiments", ["gene_set_id"], name: "index_meta_experiments_on_gene_set_id", using: :btree
  add_index "meta_experiments", ["name"], name: "index_meta_experiments_on_name", using: :btree

  create_table "species", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "scientific_name", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "studies", force: :cascade do |t|
    t.string   "accession",  limit: 255
    t.string   "title",      limit: 255
    t.string   "manuscript", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "studies", ["accession"], name: "index_studies_on_accession", using: :btree
  add_index "studies", ["title"], name: "index_studies_on_title", using: :btree

  create_table "tissues", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "type_of_values", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "type_of_values", ["name"], name: "index_type_of_values_on_name", using: :btree

  create_table "varieties", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.string   "url",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_foreign_key "experiments", "studies"
  add_foreign_key "expression_values", "experiments"
  add_foreign_key "expression_values", "genes"
  add_foreign_key "expression_values", "meta_experiments"
  add_foreign_key "expression_values", "type_of_values"
  add_foreign_key "genes", "gene_sets"
  add_foreign_key "meta_experiments", "gene_sets"
end
