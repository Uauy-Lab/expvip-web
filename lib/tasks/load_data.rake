require 'csv'  
require 'bio'
namespace :load_data do

  desc "Loads the values for a factor. The file must have 4 columns, separated by tabs: facor, order, name and short."
  task :factor, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do 
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        #puts row.inspect
        factor = Factor.find_or_create_by(
          :factor=>row["factor"],  :description=>row["name"], 
           :name=>row["short"])
        factor.order = row["order"].to_i
        factor.save!
      end
    end
  end

  desc "Loads the metadata from the metadata file"
  task :metadata, [:filename]  => :environment do |t, args|
	  	puts "Loading metadata"

	  	ActiveRecord::Base.transaction do
		  	factors = Factor.uniq.pluck(:factor)
        CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
		  	#	puts row.inspect
		  		species = Species.find_or_create_by(:scientific_name=>row["scientific_name"])
		  		
		  		#Maybe we need to validate that we are not overwritting. Look if there is a way to know if find_or_create tells which is the case. 
		  		study = Study.find_or_create_by(:accession=>row["secondary_study_accession"])
		  		study.title = 	row["study_title"]
		  		study.manuscript = row["Manuscript"]
		  		study.species = species
		  		study.save!
		  		#variety = Variety.find_or_create_by(:name=>row["Variety"])
		  		#tissue = Tissue.find_or_create_by(:name=>row["Tissue"])

		  		#We need to validate that it doesn't exist. Maybe make the accessions primary keys. 
		  		experiment = Experiment.find_or_create_by(:accession => row["run_accession"] )
		  		experiment.accession = row["run_accession"]
          #experiment.variety = variety
		  		#experiment.tissue = tissue
		  		#experiment.age = row["Age"]
		  		#experiment.stress = row["Stress/disease"]
		  		experiment.accession = row["run_accession"]
          experiment.total_reads = row["Total reads"].to_i if row["Total reads"]
          experiment.mapped_reads = row["Mapped reads"].to_i if row["Mapped reads"] 
          experiment.study = study
		  		experiment.save!



		  		experiment_group = ExperimentGroup.find_or_create_by(:name=>row["Group_number_for_averaging"], :description=>row["Group_for_averaging"])
		  		
          if experiment_group.factors.length == 0
        
            #puts "Factors not loaded yet! for #{experiment_group.name}"
            factors.each do |f|
              v = row[f]
              factor = Factor.find_by factor: f, description:v
              #puts "#{f}:#{v}:#{factor}"
              raise "#{f}:#{v} not found!. Make #{v} was loaded in the factors\n"
              experiment_group.factors << factor
            end
          end

          experiment_group.experiments << experiment
		  		


          experiment_group.save!
		  	end
	  	end
  end

  desc "Change the name of the studies"
  task :fixStudyExpression, [:filename]  => :environment do |t, args|
      puts "FixingStudies"

      ActiveRecord::Base.transaction do
        CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
          #puts row.inspect
          #species = Species.find_or_create_by(:scientific_name=>row["scientific_name"])
          
          #Maybe we need to validate that we are not overwritting. Look if there is a way to know if find_or_create tells which is the case. 
          puts row["secondary_study_accession"]
          study = Study.find_by(:accession=>row["secondary_study_accession"])
          puts study.inspect
          #We need to validate that it doesn't exist. Maybe make the accessions primary keys. 
          experiment = Experiment.find_by(:accession=>row["run_accession"])
          experiment.study = study
          puts experiment.inspect
          experiment.save!
        end
      end
  end


  desc "Load the genes, from the ENSEMBL fasta file."
  task :ensembl_genes, [:gene_set, :filename] => :environment do |t, args|
  	puts "Loading genes"
  	ActiveRecord::Base.transaction do
  		gene_set = GeneSet.find_or_create_by(:name=>args[:gene_set])

  		Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
  			ff.each do |entry|
    			arr = entry.definition.split( / description:"(.*?)" *| / )
    			g = Gene.new 
    			g.gene_set = gene_set
    			g.name = arr.shift
				  
          arr.each { |e| g.add_field(e) }
				  g.save!
  			end
		end
  	end
  end

  #def get_experiment(name)
  #	@experiments[name] = Experiment.find_by(:accession=>name) unless @experiments[name]
  #	return @experiments[name]
  #end

  desc "Load the homology values. The headers of the table must be: Gene  A B D Group Genome. The gene corresponds to the gene name, not the specific transcript"
  task :homology, [:gene_set, :filename] => :environment do |t, args|
    puts args 
    ActiveRecord::Base::transaction do
       conn = ActiveRecord::Base.connection
       gene_set = GeneSet.find_by(:name=>args[:gene_set])
       genes = Hash.new
       Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|  
        genes[g.gene] = g
       end
       puts "Loaded #{genes.size} genes  in memory"
       count = 0

       CSV.foreach(args[:filename], :headers=>true, :col_sep=>"\t") do |row|
        h = Homology.new
        #Gene A B D Group Genome
      
        h.gene = genes[row["Gene"]]
        h.A = genes[row["A"]]
        h.B = genes[row["B"]]
        h.D = genes[row["D"]]
        h.genome = row["Genome"]
        h.group = row["Group"]
        h.save!
        count += 1
        if count % 10000 == 0
          puts "Loaded #{count} Homologies (#{row['Gene']})" 
        end
       end
       puts "Loaded #{count} Homologies"
    end
  end

  desc "Load the values from a csv file"
  task :values, [:meta_experiment, :gene_set, :value_type, :filename ] => :environment do |t, args| 
  	puts args
    ActiveRecord::Base::transaction do
      conn = ActiveRecord::Base.connection
  		meta_exp = MetaExperiment.find_or_create_by(:name=>args[:meta_experiment])
  		gene_set = GeneSet.find_by(:name=>args[:gene_set])
  		value_type = TypeOfValue.find_or_create_by(:name=>args[:value_type])
  		experiments = Hash.new
      meta_exp.gene_set = gene_set
      #TODO: add validation if any of the find_by is null

  		#genes_arr = Gene.connection.select_all("SELECT * FROM clients WHERE id = '1'")
  		genes = Hash.new
  		Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|  
  			genes[g.name] = g.id
  		end
      puts "Loaded #{genes.size} genes  in memory"

      Experiment.find_each do | e |
        experiments[e.accession] = e.id
      end  
      puts "Loaded #{experiments.size} experiments  in memory"
      count = 0
  		inserts = Array.new
  		CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
  			#puts row.inspect
        #puts meta_exp.inspect
  			#gene = Gene.find_by(:name=>row["target_id"])
        gene_name = row["target_id"]
  			gene = genes[gene_name]
  			#puts gene.inspect
  			row.delete("target_id")
  			row.to_hash.each_pair do |name, val| 
  				val = val.to_f
          raise  "Experiment #{name} not found " unless experiments[name]
          raise  "Gene #{gene_name} not found in gene set #{args[:gene_set]} " unless gene
          str = "(#{experiments[name]},#{gene},#{meta_exp.id},#{value_type.id},#{val},NOW(),NOW())"
          inserts.push str          
  			end
  			count += 1
        if count % 1000 == 0
          puts "Loaded #{count} ExpressionValue (#{gene_name})" 
          sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
          #puts sql
          conn.execute sql
          inserts = Array.new
        end
  		end
      puts "Loaded #{count} ExpressionValue " 
      sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
      #puts sql
      conn.execute sql
  	end
  end
end
