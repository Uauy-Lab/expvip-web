json.array!(@meta_experiments) do |meta_experiment|
  json.extract! meta_experiment, :id, :name, :description, :gene_set_id
  json.url meta_experiment_url(meta_experiment, format: :json)
end
