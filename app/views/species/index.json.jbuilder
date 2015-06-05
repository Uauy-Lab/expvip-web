json.array!(@species) do |species|
  json.extract! species, :id, :name, :scientific_name
  json.url species_url(species, format: :json)
end
