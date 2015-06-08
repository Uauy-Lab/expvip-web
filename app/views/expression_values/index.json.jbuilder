json.array!(@expression_values) do |expression_value|
  json.extract! expression_value, :id, :experiment_id, :gene_id, :meta_experiment_id, :type_of_value_id, :value
  json.url expression_value_url(expression_value, format: :json)
end
