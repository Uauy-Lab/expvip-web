json.array!(@genes) do |gene|
  json.extract! gene, :id, :name, :cdna, :possition, :gene, :transcript
  json.url gene_url(gene, format: :json)
end
