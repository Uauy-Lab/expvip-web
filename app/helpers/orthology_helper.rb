	module OrthologyHelper
		def self.load_homology_pairs(gene_set, filename)
			ActiveRecord::Base::transaction do
				gene_set = GeneSet.find_by(:name => gene_set)
				genes = Hash.new
				Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}' ORDER BY gene").each do |g|
					genes[g.gene] = g unless genes[g.gene]
				end
				puts "Loaded #{genes.size} genes  in memory"
				count = 0

				CSV.foreach(filename, :headers => true, :col_sep => "\t") do |row|
					h = HomologyPair.new
					h.homology = row["homology_id"].to_i
					h.gene = genes[row["genes"]]
					h.cigar = row["cigar_line"]
					h.cigar = nil if row["cigar_line"] != nil and row["cigar_line"].length > 254
					h.perc_cov = row["perc_cov"].to_f
					h.perc_id = row["perc_id"].to_f
					h.perc_pos = row["perc_pos"].to_f
					h.save!
					count += 1
					if count % 10000 == 0
					puts "Loaded #{count} Homologies (#{row["homology_id"]})"
					end
				end
				puts "Loaded #{count} Homologies"
			end
		end

		def self.load_orthologs(orth_set, stream)
			ActiveRecord::Base::transaction do
				os = OrthologSet.find_or_create_by(name: orth_set)
				puts os.inspect
				count = 0
				csv = CSV.new(stream, :headers => true, :col_sep => "\t")
				gene_sets = Hash.new do |h,k| 
					puts "Loading #{k}"
					h[k] = GeneSet.find_by(name: k).to_h 
					puts "Loaded #{h[k].size} genes  in memory"
					h[k]
				end
				i = 0 
				csv.each do |row|
					begin
						og = OrthologGroup.find_or_create_by(name: row["name"], ortholog_set: os)
						puts "#{i}:#{row}" if i % 1000 == 0
						i += 1
						row.each_pair do |geneset, transcripts|
							next if geneset == "name"
							next unless transcripts
							transcripts.split(",").each do |g| 
								next unless g
								g = g.delete(" \t\r\n")
								next if g == "-"
								gs = gene_sets[geneset]
								gene =  gs[g]
								og.genes << gene
							end
						end
						og.save!
						count += 1
						os.ortholog_groups << og				
					rescue => exception
						$stderr.puts "#{i}"
						$stderr.puts row 
						$stderr.puts row.inspect
						raise exception
					end
				end
				os.save!
			end
		end

		def self.getOrthologueValuesForGene(transcripts, ret)
			all_og = Hash.new {|h,k| h[k] = Hash.new }
			genes_to_find = Hash.new
			transcripts.each do |t|  
				t.ortholog_groups.each do |og|
					ogs = og.ortholog_set 
					all_og[ogs.name]["description"]    = ogs.description ? ogs.description : ogs.name
					all_og[ogs.name]["selected"]       = ogs.selected 
					all_og[ogs.name]["name"]           = ogs.name 
					all_og[ogs.name]["genes"]          = Array.new
					og.genes.each do |g|
						all_og[ogs.name]["genes"] << {
							"gene" => g.gene, 
							"gene_set" =>  g.gene_set.name, 
							"full_name" => g.full_gene_name,
							"chromosome" => g.chromosome,
							"genome" => g.genome,
							"group" => og.name
						}
						genes_to_find[g.full_gene_name] = g
					end
				end
			end
			ret["ortholog_groups"] = all_og
			genes_to_find.each_pair do |k, g|
				transcripts = GenesHelper.findTranscripts(g.gene, g.gene_set)
				ret["values"][k] = ExpressionValuesHelper.getValuesForTranscripts(transcripts)
			end

		end

	end