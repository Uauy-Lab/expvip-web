json.array!(@experiments) do |experiment|
  json.extract! experiment, :id, :variety, :tissue, :age, :stress, :accession
  json.url experiment_url(experiment, format: :json)
end
