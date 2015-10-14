namespace :export do
  desc "Exports the table for Deseq2"
  task :values, [:unit, :file]  => :environment do |t, args|
  	unit = args[:unit]
  	outF = args[:file]
  	File.open(outF, "w") do |file|  
  		ExpressionValuesHelper::getValuesTable(expressionUnit:unit) do |row|
  			file.puts row.join("\t")
  		end
  	end
  end

end
