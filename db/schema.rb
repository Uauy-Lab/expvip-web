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

ActiveRecord::Schema.define(version: 20160104181636) do

  create_table "ExperimentGroups_Factors", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "experiment_group_id", null: false
    t.integer "factor_id",           null: false
  end

  create_table "experiment_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "experiment_groups_experiments", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "experiment_group_id", null: false
    t.integer "experiment_id",       null: false
    t.index ["experiment_group_id"], name: "index_experiment_groups_experiments_on_experiment_group_id", using: :btree
    t.index ["experiment_id"], name: "index_experiment_groups_experiments_on_experiment_id", using: :btree
  end

  create_table "experiments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "accession"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "study_id"
    t.integer  "total_reads"
    t.integer  "mapped_reads"
    t.index ["accession"], name: "index_experiments_on_accession", using: :btree
    t.index ["study_id"], name: "index_experiments_on_study_id", using: :btree
  end

  create_table "expression_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "experiment_id"
    t.integer  "gene_id"
    t.integer  "meta_experiment_id"
    t.integer  "type_of_value_id"
    t.float    "value",              limit: 24
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["experiment_id"], name: "index_expression_values_on_experiment_id", using: :btree
    t.index ["gene_id"], name: "index_expression_values_on_gene_id", using: :btree
    t.index ["meta_experiment_id"], name: "index_expression_values_on_meta_experiment_id", using: :btree
    t.index ["type_of_value_id"], name: "index_expression_values_on_type_of_value_id", using: :btree
  end

  create_table "factors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.integer  "order"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "factor"
    t.index ["factor"], name: "index_factors_on_factor", using: :btree
  end

  create_table "gene_sets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "genes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "cdna"
    t.string   "possition"
    t.string   "gene"
    t.string   "transcript"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "gene_set_id"
    t.text     "description", limit: 65535
    t.index ["gene_set_id"], name: "index_genes_on_gene_set_id", using: :btree
    t.index ["name"], name: "index_genes_on_name", using: :btree
  end

  create_table "homologies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "gene_id"
    t.integer  "group"
    t.string   "genome"
    t.integer  "A_id"
    t.integer  "B_id"
    t.integer  "D_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gene_id"], name: "index_homologies_on_gene_id", using: :btree
  end

  create_table "meta_experiments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.integer  "gene_set_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["gene_set_id"], name: "index_meta_experiments_on_gene_set_id", using: :btree
    t.index ["name"], name: "index_meta_experiments_on_name", using: :btree
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "session_id",               null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "species", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "scientific_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "studies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "accession"
    t.string   "title"
    t.string   "manuscript"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "species_id"
    t.index ["accession"], name: "index_studies_on_accession", using: :btree
    t.index ["species_id"], name: "index_studies_on_species_id", using: :btree
    t.index ["title"], name: "index_studies_on_title", using: :btree
  end

  create_table "tissues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "type_of_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["name"], name: "index_type_of_values_on_name", using: :btree
  end

  create_table "varieties", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.string   "url"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_foreign_key "experiments", "studies"
  add_foreign_key "expression_values", "experiments"
  add_foreign_key "expression_values", "genes"
  add_foreign_key "expression_values", "meta_experiments"
  add_foreign_key "expression_values", "type_of_values"
  add_foreign_key "genes", "gene_sets"
  add_foreign_key "homologies", "genes"
  add_foreign_key "meta_experiments", "gene_sets"
  add_foreign_key "studies", "species"
end
