
require 'csv'

homologyFilename = ARGV[0]

three_homoeologues = ARGV[1]
countsFile = ARGV[2]

class Gene
	attr_accessor :homologies, :name
	def initialize(name)
		@name = name
		@homologies = Array.new
	end


	def chromosome
		ret = name.split("_")[1] 
		ret = "3B" if !name.nil? and name.start_with? "TRAES3B"
		ret = name.split("_")[2] if  name.start_with? "TRIAE_CS42" 
		ret = name.gsub("TraesCS","")[0,2] if(name.start_with? "TraesCS")
		
		ret
	end

	def group

		chromosome[0]
	end

	def genome
		chromosome[1]
	end

	def genome_index
		case genome
		when "A"
			return 1
		when "B"
			return 2
		when "D"
			return 3
		end
		return 4
	end
end

class Homology
	attr_accessor :rows, :id
	def initialize(id)
		@id = id
		@rows = Array.new
	end
	def to_s
		rows["genes"]
	end	
end


currentHomology = Homology.new(0)
genes = Hash.new

CSV.foreach(homologyFilename, headers: true, col_sep: "\t") do |row|
  #puts row.inspect
  if currentHomology.id != row["homology_id"]
  	currentHomology = Homology.new(row["homology_id"])
  end
  currentHomology.rows << row
  genes[row["genes"]] = Gene.new(row["genes"]) unless genes[row["genes"]]
  genes[row["genes"]].homologies << currentHomology

  row["gene"] = genes[row["genes"]]
end

out_three = File.open(three_homoeologues, "w")
to_print = ["Gene", "A", "B", "D", "Group", "Genome"]
out_three.puts to_print.join("\t")

counts = Hash.new(0)
genes.each_pair do |name, gene|  
	next unless gene.chromosome
	to_print = Array.new(4)
	to_print[0] = name
	group = gene.group
	genome = gene.genome
	total_homs = 0
	#if gene.homologies.size > 3
	#	gene.homologies.each { |e|  e.rows.each { |i| puts [i["genes"], i["perc_cov"], i["perc_id"], i["perc_pos"]].join("\t") } }
	#end
	gene.homologies.each do |h|
		h.rows.each do |r|  
			g = r["gene"]
			total_homs += 1 unless g.name == name
			if g.chromosome and  g.group == group 
				to_print[g.genome_index] = r unless to_print[g.genome_index]
				to_print[g.genome_index] = r if to_print[g.genome_index]["perc_pos"].to_f < r["perc_pos"].to_f 
			end
		end
	end
	to_print.map! {|item| item["gene"].name if  item and not item.is_a? String and item["gene"]}
	to_print[0] = name
	sum = to_print.collect do| c | 
		ret = 0
		ret = 1 if c
		ret
	end.inject(:+)
	#puts sum 
	to_print << group
	to_print << genome
	counts[total_homs] += 1
	out_three.puts to_print.join("\t")  # if sum == 4
end

out_three.close

open(countsFile, "w") { |io| counts.keys.sort.each { |name| io.puts "#{name}\t#{counts[name]}"  } }
