require "csv"
require "bio"
namespace :load_data do
  desc "Loads the values for a factor. The file must have 4 columns, separated by tabs: facor, order, name and short."
  task :factor, [:filename] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      dfos = Hash.new 
      DefaultFactorOrder.all.each do |single|
        dfos[single.name] = single
      end
     # puts dfos.inspect
      CSV.foreach(args[:filename], :headers => true, :col_sep => "\t") do |row|
        #puts row["factor"]
        factor = Factor.find_or_create_by(
          :default_factor_order => dfos[row["factor"]],
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
      dfos = Hash.new 
      DefaultFactorOrder.all.each do |single|
        dfos[single.name] = single
      end
      # factors = Factor.distinct.pluck(:factor)
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

        dfos.each_pair do |f, dfo|
          next if f == "study" #TODO: this is a patch on a patch! Need to make sure that study is the first on the plot
          v = row[f]
          #puts row.inspect
          factor = Factor.find_by default_factor_order: dfo, description: v
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
    GenesHelper.load_ensembl_genes(args[:gene_set], args[:filename])
  end

  desc "Load the genes, from a fasta file.  '=' is used on each field "
  task :gff_produced_genes, [:gene_set, :filename] => :environment do |t, args|
    GenesHelper.load_gff_produced_gens(args[:gene_set], args[:filename])
  end

  desc "Load the genes, from a de novo assembly. "
  task :de_novo_genes, [:gene_set, :filename] => :environment do |t, args|
    GenesHelper.load_de_novo_genes(args[:gene_set], args[:filename])
  end

  desc "Load the genes, from the wheat pangenome project. The gene is parsed from the transcript name. "
  task :pangenome_cdna, [:gene_set, :filename] => :environment do |t, args|
    puts "Loading genes"
    GenesHelper.load_pangenome_cdna(args[:gene_set], args[:filename])
  end

  desc "Load homology in a pairwaise manner"
  task :homology_pairs, [:gene_set, :filename] => :environment do |t, args|
    puts args
    OrthologyHelper.load_homology_pairs(args[:gene_set], args[:filename])
  end

  desc "Load orthologs"
  task :orthologs, [:orth_set, :filename] => :environment do |t, args|
    puts args
    Zlib::GzipReader.open(args[:filename]) do | stream|
      OrthologyHelper.load_orthologs(args[:orth_set], stream)
    end
  end

  desc "Load the values from a tsv file"
  task :values_mongo, [:meta_experiment, :gene_set, :value_type, :filename] => :environment do |t, args|
    puts args
    ActiveRecord::Base::transaction do
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
