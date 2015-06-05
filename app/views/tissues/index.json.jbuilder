json.array!(@tissues) do |tissue|
  json.extract! tissue, :id, :name, :description
  json.url tissue_url(tissue, format: :json)
end
