require "csv"
require "bio"
namespace :load_data do
  desc "Loads the values for a factor. The file must have 4 columns, separated by tabs: facor, order, name and short."
  task :factor, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        factor = Factor.find_or_create_by(
          :factor => row["factor"],
          :description => row["name"],
        )
        factor.name = row["short"]
        factor.order = row["order"].to_i
        factor.save!
      end
    end
  end

  desc "Loads the metadata from the metadata file"
  task :metadata, [:filename] => :environment do |t, args|
    puts "Loading metadata"

    ActiveRecord::Base.transaction do
      factors = Factor.distinct.pluck(:factor)
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        #	puts row.inspect
        species = Species.find_or_create_by(:scientific_name => row["scientific_name"])

        #Maybe we need to validate that we are not overwritting. Look if there is a way to know if find_or_create tells which is the case.
        study = Study.find_or_create_by(:accession => row["secondary_study_accession"])
        study.title = row["study_title"]
        study.manuscript = row["Manuscript"]
        study.species = species
        study.active = 1
        study.save!

        #We need to validate that it doesn't exist. Maybe make the accessions primary keys.
        experiment = Experiment.find_or_create_by(:accession => row["run_accession"])
        experiment.accession = row["run_accession"]
        experiment.total_reads = row["Total reads"].to_i if row["Total reads"]
        experiment.mapped_reads = row["Mapped reads"].to_i if row["Mapped reads"]
        experiment.study = study

        factors.each do |f|
          v = row[f]
          factor = Factor.find_by factor: f, description: v
          raise "'#{f}:#{v}' not found!. Make sure '#{v}' was loaded in the factors\n" unless factor

          experiment.factors << factor
        end
        experiment.save!
      end
    end
  end

  desc "Change the name of the studies"
  task :fixStudyExpression, [:filename] => :environment do |t, args|
    puts "FixingStudies"
    ActiveRecord::Base.transaction do
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        puts row["secondary_study_accession"]
        study = Study.find_by(:accession => row["secondary_study_accession"])
        puts study.inspect
        #We need to validate that it doesn't exist. Maybe make the accessions primary keys.
        experiment = Experiment.find_by(:accession => row["run_accession"])
        experiment.study = study
        experiment.save!
      end
    end
  end

  desc "Load the genes, from the ENSEMBL fasta file."
  task :ensembl_genes, [:gene_set, :filename] => :environment do |t, args|
    puts "Loading Ensembl genes"
    ActiveRecord::Base.transaction do
      gene_set = GeneSet.find_or_create_by(:name => args[:gene_set])
      #puts gene_set.inspect
      Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
        ff.each do |entry|
          arr = entry.definition.split(/ description:"(.*?)" *| /)
          g = Gene.new
          g.gene_set = gene_set
          g.name = arr.shift
          arr.each { |e| g.add_field(e) }
          g.save!
          #GenesHelper.saveGene(g)
        end
      end
    end
  end

  desc "Load the genes, from a fasta file.  '=' is used on each field "
  task :gff_produced_genes, [:gene_set, :filename] => :environment do |t, args|
    puts "Loading gff produced genes"
    i = 0
    ActiveRecord::Base.transaction do
      gene_set = GeneSet.find_or_create_by(:name => args[:gene_set])
      puts gene_set.inspect
      Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
        ff.each do |entry|
          arr = entry.definition.split(/\s|\t/)
          g = Gene.new
          g.gene_set = gene_set
          g.name = arr.shift
          fields = Hash.new
          arr.each do |e|
            f = e.split("=")
            fields[f[0]] = f[1]
          end
          g.transcript = g.name
          g.gene = fields["gene"]
          g.cdna = fields["biotype"]
          g.save!
          #GenesHelper.saveGene(g)
          i += 1
          puts "Loaded #{i} genes (#{g.transcript})" if i % 1000 == 0
        end
      end
    end
    puts "Loaded #{i} genes"
  end

  desc "Load the genes, from a de novo assembly. "
  task :de_novo_genes, [:gene_set, :filename] => :environment do |t, args|
    puts "Loading genes"
    ActiveRecord::Base.transaction do
      gene_set = GeneSet.find_or_create_by(:name => args[:gene_set])

      Bio::FlatFile.open(Bio::FastaFormat, args[:filename]) do |ff|
        ff.each do |entry|
          arr = entry.definition.split(/ description:"(.*?)" *| /)
          g = Gene.new
          g.gene_set = gene_set
          name = arr.shift
          g.name = name
          g.transcript = name
          g.cdna = name
          #GenesHelper.saveGene(g)
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
  task :homology_deprecated, [:gene_set, :filename] => :environment do |t, args|
    puts args
    ActiveRecord::Base::transaction do
      conn = ActiveRecord::Base.connection
      gene_set = GeneSet.find_by(:name => args[:gene_set])
      genes = Hash.new
      Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}' ORDER BY gene").each do |g|
        genes[g.gene] = g unless genes[g.gene]
      end
      puts "Loaded #{genes.size} genes  in memory"
      count = 0

      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        h = Homology.new
        #Gene A B D Group Genome
        #puts row["Gene"].inspect
        #puts  genes[row["Gene"]].inspect
        #puts h.inspect
        h.Gene = genes[row["Gene"]]
        h.A = genes[row["A"]]
        h.B = genes[row["B"]]
        h.D = genes[row["D"]]
        h.genome = row["Genome"]
        h.group = row["Group"]
        h.save!
        count += 1
        if count % 10000 == 0
          puts "Loaded #{count} Homologies (#{row["Gene"]})"
        end
      end
      puts "Loaded #{count} Homologies"
    end
  end

  desc "Load homology in a pairwaise manner"
  task :homology_pairs, [:gene_set, :filename] => :environment do |t, args|
    puts args
    ActiveRecord::Base::transaction do
      conn = ActiveRecord::Base.connection
      gene_set = GeneSet.find_by(:name => args[:gene_set])
      genes = Hash.new
      Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}' ORDER BY gene").each do |g|
        genes[g.gene] = g unless genes[g.gene]
      end
      puts "Loaded #{genes.size} genes  in memory"
      count = 0

      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
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

  desc "Load the values from a csv file"
  task :values, [:meta_experiment, :gene_set, :value_type, :filename] => :environment do |t, args|
    puts args
    ActiveRecord::Base::transaction do
      conn = ActiveRecord::Base.connection
      meta_exp = MetaExperiment.find_or_create_by(:name => args[:meta_experiment])
      gene_set = GeneSet.find_by(:name => args[:gene_set])
      value_type = TypeOfValue.find_or_create_by(:name => args[:value_type])
      experiments = Hash.new
      meta_exp.gene_set = gene_set
      #TODO: add validation if any of the find_by is null

      genes = Hash.new
      Gene.find_by_sql("SELECT * FROM genes where gene_set_id='#{gene_set.id}'").each do |g|
        genes[g.name] = g.id
      end
      puts "Loaded #{genes.size} genes  in memory"

      Experiment.find_each do |e|
        experiments[e.accession] = e.id
      end
      puts "Loaded #{experiments.size} experiments  in memory"
      count = 0
      inserts = Array.new
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        gene_name = row["target_id"]
        gene_name = row["transcript"] unless row["target_id"]
        gene = genes[gene_name]
        row.delete("target_id")
        row.delete("transcript")
        row.to_hash.each_pair do |name, val|
          val = val.to_f
          raise "Experiment #{name} not found " unless experiments[name]
          raise "Gene #{gene_name} not found in gene set #{args[:gene_set]} " unless gene
          str = "(#{experiments[name]},#{gene},#{meta_exp.id},#{value_type.id},#{val},NOW(),NOW())"
          inserts.push str
        end
        count += 1
        if count % 10 == 0
          puts "Loaded #{count} ExpressionValue (#{gene_name})"
          sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
          conn.execute sql
          inserts = Array.new
        end
      end
      puts "Loaded #{count} ExpressionValue "
      sql = "INSERT INTO expression_values (`experiment_id`,`gene_id`, `meta_experiment_id`, `type_of_value_id`, `value`,`created_at`, `updated_at`) VALUES #{inserts.join(", ")}"
      conn.execute sql
    end
  end

  desc "Load the values from a tsv file"
  task :values_mongo, [:meta_experiment, :gene_set, :value_type, :filename] => :environment do |t, args|
    puts args
    ActiveRecord::Base::transaction do
      conn = ActiveRecord::Base.connection
      gene_set = GeneSet.find_by(:name => args[:gene_set])
      meta_exp = MetaExperiment.find_or_create_by(:name => args[:meta_experiment], :gene_set => gene_set)
      value_type = TypeOfValue.find_or_create_by(:name => args[:value_type])
      experiments = Hash.new

      #TODO: add validation if any of the find_by is null
      genes = GenesHelper.load_gene_hash(gene_set)
      extension = File.extname(args[:filename])
      puts "Loaded #{genes.size} genes  in memory (#{extension}) "
      missing = []
      Experiment.find_each do |e|
        experiments[e.accession] = e.id
      end
      puts "Loaded #{experiments.size} experiments  in memory"
      count = 0
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        missing = ExpressionValuesHelper.add(row, genes, experiments, meta_exp, value_type, nil)
        count += 1
      end unless extension == ".gz"

      Zlib::GzipReader.open(args[:filename]) do |gzip|
        csv = CSV.new(gzip, :headers => true, :col_sep => "\t")

        csv.each do |row|
          missing = ExpressionValuesHelper.add(row, genes, experiments, meta_exp, value_type, nil)
          count += 1
        end
      end if extension == ".gz"
      puts "Loaded #{count} ExpressionValue "
      puts "Missing #{missing.to_a.join(",")}" if missing.size > 0
    end
  end

  desc "Selects default studies (Provide text file which contains study names/accession in each line)"
  task :default_studies, [:filename] => :environment do |t, args|
    puts "file provided #{args.filename}"
    default_studies = File.open(args.filename).read
    default_studies.gsub!(/\r\n?/, "")
    studs = []
    default_studies.each_line do |line|
      print "Study #{line}"
      studs.push(line.gsub(/\n/, ""))
    end
    puts "these are studs: #{studs}"
    ActiveRecord::Base.transaction do
      Study.all.each do |study|
        if studs.include?(study.accession)
          study.update_attribute :selected, true
          puts "Found and Selected: #{study.accession}"
        else
          study.update_attribute :selected, false
        end
      end
    end
  end

  desc "Adding sample genes - Provide a file with each row containing gene_set_name, gene_name, Kind (search/compare/heatmap)"
  task :sample_genes, [:filename] => :environment do |t, args|
    puts "file provided #{args.filename}"
    genes = File.open(args.filename).read
    genes.gsub!(/\r\n?/, "")
    all_genes = []
    ActiveRecord::Base.transaction do
      SampleGene.delete_all
      genes.each_line do |line|
        line.gsub!(/\n/, "")
        all_genes = line.split(/, */).map {
          |x|
          if x =~ /\A\d+\z/ ? true : false
            x.to_i
          else
            x
          end
        }
        gene_id = Gene.find_by(:name => all_genes[1])
        gene_set_id = GeneSet.find_by(:name => all_genes[0])

        SampleGene.find_or_create_by(:gene_set_id => gene_set_id.id, :gene_id => gene_id.id, :kind => all_genes[2])
        puts "Add #{all_genes}"
      end
    end
  end

  desc "Selecting a default gene set (Provide gene set name)"
  task :default_gene_set, [:gene_set] => :environment do |t, args|
    puts "gene set provided #{args.gene_set}"
    ActiveRecord::Base.transaction do
      GeneSet.all.each do |gene_set|
        if gene_set.name == args.gene_set
          puts "Found #{args.gene_set} in the database"
          gene_set.update_attribute :selected, true
          puts "Selected #{args.gene_set} gene set as the default"
        else
          puts "Set #{gene_set.name} as a non default gene set"
          gene_set.update_attribute :selected, false
        end
      end
    end
  end

  desc "Load the expression bias"
  task :expression_bias, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      CSV.foreach(args[:filename], headers: true, col_sep: ",") do |row|
        puts row.inspect
        eb = ExpressionBias.find_or_create_by(name: row["dataset"])
        eb.order = row["order"].to_i
        puts eb
        ebv = ExpressionBiasValue.find_or_create_by(expression_bias: eb, decile: row["decile"].to_i)
        ebv.min = row["min"].to_f
        ebv.max = row["max"].to_f
        eb.save!
        ebv.save!
      end
    end
  end

  desc "Populate the default factor order table (provide a txt file with each line being [name of the factor, active?(0/1)] in the order that you want"
  task :default_factor_order, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      DefaultFactorOrder.destroy_all
      factorIndex = 1
      text = File.open(args[:filename]).read
      text.gsub!(/\r\n?/, "")
      text.each_line do |factor|
        begin
          line_content = factor.split(",")
          puts line_content[0].to_s
          DefaultFactorOrder.create(name: line_content[0].to_s.gsub(/\n/, ""), order: factorIndex, selected: line_content[1])
          factorIndex += 1
        rescue => exception
          puts "Factor: #{factor.gsub(/\n/, "")} could not be found in the database\n#{exception}"
        end
      end
    end
  end

  desc "Populate the links table with URL that contain placeholdersi(<gene>) for genes (format: {URL, site_name} in each line)"
  task :links, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      begin
        data = File.open(args[:filename]).read
        data.gsub!(/\r\n?/, "")
        data.each_line do |url|
          raise "URL: #{url} doesn't include a placeholder (<gene>)" unless url.include?("<gene>")
          puts url.to_s
          site = url.gsub(/\s+/, "").split(",")
          Link.find_or_create_by(url: site[0].to_s, site_name: site[1].to_s)
        end
      rescue StandardError => e
        puts "There was an issue processing the file.\nMake sure each URL is in a seperate line and contains a placeholder (<gene>)\n#{e}"
      end
    end
  end
end
