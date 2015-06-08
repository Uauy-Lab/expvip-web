json.array!(@type_of_values) do |type_of_value|
  json.extract! type_of_value, :id, :name, :description
  json.url type_of_value_url(type_of_value, format: :json)
end
