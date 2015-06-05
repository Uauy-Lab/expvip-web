json.array!(@experiment_groups) do |experiment_group|
  json.extract! experiment_group, :id, :name, :description
  json.url experiment_group_url(experiment_group, format: :json)
end
