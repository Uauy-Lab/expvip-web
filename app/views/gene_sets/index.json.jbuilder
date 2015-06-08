json.array!(@gene_sets) do |gene_set|
  json.extract! gene_set, :id, :name, :description
  json.url gene_set_url(gene_set, format: :json)
end
