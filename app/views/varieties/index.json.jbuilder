json.array!(@varieties) do |variety|
  json.extract! variety, :id, :name, :description, :url
  json.url variety_url(variety, format: :json)
end
