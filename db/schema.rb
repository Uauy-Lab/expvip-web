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

ActiveRecord::Schema.define(version: 2021_12_17_181226) do

  create_table "ExperimentGroups_Factors", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "ExperimentGroup_id", null: false
    t.integer "Factor_id", null: false
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "default_factor_orders", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.integer "selected"
  end

  create_table "experiment_groups", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "experiment_groups_experiments", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "experiment_group_id", null: false
    t.integer "experiment_id", null: false
    t.index ["experiment_group_id"], name: "index_experiment_groups_experiments_on_experiment_group_id"
    t.index ["experiment_id"], name: "index_experiment_groups_experiments_on_experiment_id"
  end

  create_table "experiments", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "accession"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "study_id"
    t.integer "total_reads"
    t.integer "mapped_reads"
    t.index ["accession"], name: "index_experiments_on_accession"
    t.index ["study_id"], name: "index_experiments_on_study_id"
  end

  create_table "experiments_factors", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.bigint "experiment_id", null: false
    t.bigint "factor_id", null: false
    t.index ["experiment_id", "factor_id"], name: "index_experiments_factors_on_experiment_id_and_factor_id"
  end

  create_table "expression_bias", charset: "latin1", force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expression_bias_values", charset: "latin1", force: :cascade do |t|
    t.integer "decile"
    t.float "min"
    t.float "max"
    t.bigint "expression_bias_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expression_bias_id"], name: "index_expression_bias_values_on_expression_bias_id"
  end

  create_table "expression_values", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "gene_id"
    t.integer "meta_experiment_id"
    t.integer "type_of_value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gene_id"], name: "index_expression_values_on_gene_id"
    t.index ["meta_experiment_id"], name: "index_expression_values_on_meta_experiment_id"
    t.index ["type_of_value_id"], name: "index_expression_values_on_type_of_value_id"
  end

  create_table "factors", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_factor_order_id"
    t.index ["default_factor_order_id"], name: "index_factors_on_default_factor_order_id"
  end

  create_table "gene_sets", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "selected"
  end

  create_table "genes", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "cdna"
    t.string "possition"
    t.string "gene"
    t.string "transcript"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gene_set_id"
    t.text "description"
    t.index ["gene"], name: "index_genes_on_gene"
    t.index ["gene_set_id"], name: "index_genes_on_gene_set_id"
    t.index ["name"], name: "index_genes_on_name"
    t.index ["transcript"], name: "index_genes_on_transcript"
  end

  create_table "homologies", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "gene_id"
    t.integer "group"
    t.string "genome"
    t.integer "A_id"
    t.integer "B_id"
    t.integer "D_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gene_id"], name: "index_homologies_on_gene_id"
  end

  create_table "homology_pairs", charset: "utf8mb3", force: :cascade do |t|
    t.integer "homology"
    t.string "cigar"
    t.decimal "perc_cov", precision: 7, scale: 4
    t.decimal "perc_id", precision: 7, scale: 4
    t.decimal "perc_pos", precision: 7, scale: 4
    t.bigint "gene_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gene_id"], name: "index_homology_pairs_on_gene_id"
    t.index ["homology"], name: "index_homology_pairs_on_homology"
  end

  create_table "links", charset: "utf8mb3", force: :cascade do |t|
    t.string "url"
    t.string "site_name"
  end

  create_table "meta_experiments", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "gene_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gene_set_id"], name: "index_meta_experiments_on_gene_set_id"
    t.index ["name"], name: "index_meta_experiments_on_name"
  end

  create_table "sample_genes", charset: "utf8mb3", force: :cascade do |t|
    t.integer "gene_set_id"
    t.integer "gene_id"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "species", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "scientific_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "studies", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "accession"
    t.string "title"
    t.string "manuscript", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "species_id"
    t.boolean "selected"
    t.string "summary", limit: 500
    t.string "sra_description", limit: 500
    t.string "grouping"
    t.string "doi"
    t.integer "order"
    t.boolean "active"
    t.index ["accession"], name: "index_studies_on_accession"
    t.index ["species_id"], name: "index_studies_on_species_id"
    t.index ["title"], name: "index_studies_on_title"
  end

  create_table "type_of_values", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_type_of_values_on_name"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "experiments", "studies"
  add_foreign_key "expression_bias_values", "expression_bias", column: "expression_bias_id"
  add_foreign_key "expression_values", "genes"
  add_foreign_key "expression_values", "meta_experiments"
  add_foreign_key "expression_values", "type_of_values"
  add_foreign_key "factors", "default_factor_orders"
  add_foreign_key "genes", "gene_sets"
  add_foreign_key "homologies", "genes"
  add_foreign_key "meta_experiments", "gene_sets"
  add_foreign_key "studies", "species"
end
