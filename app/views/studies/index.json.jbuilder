json.array!(@studies) do |study|
  json.extract! study, :id, :species, :title, :manuscript
  json.url study_url(study, format: :json)
end
