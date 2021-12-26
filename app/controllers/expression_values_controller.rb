require "json"

class ExpressionValuesController < ApplicationController
  before_action :set_expression_value, only: [:show, :edit, :update, :destroy]

  def getValuesToCompareTranscipts(gene, compare)
    values = Hash.new
    values[gene.name]    = ExpressionValuesHelper.getValuesForTranscript(gene)
    values[compare.name] = ExpressionValuesHelper.getValuesForTranscript(compare)
    return values
  end

  def getValuesToCompareGene(gene_name, compare_name, gene, compare)
    values = Hash.new
    values[gene_name]    = ExpressionValuesHelper.getValuesForTranscripts(gene)
    values[compare_name] = ExpressionValuesHelper.getValuesForTranscripts(compare)
    return values
  end

  def gene
    ret = Hash.new
    gene_name = params["name"]
    compare_name = params["compare"]
    gene_set_name = params["gene_set"]
    gene_set = GeneSet.find_by name: gene_set_name

    transcripts = GenesHelper.findTranscripts(gene_name, gene_set)
    compare = GenesHelper.findTranscripts(compare_name, gene_set) if compare_name
    ret["gene"] = gene_name
    values = Hash.new
    if compare.size > 0
      values = HomologyHelper.getValuesToCompareGene(gene_name, compare_name, transcripts, compare)
      ret["compare"] = compare_name
    else
      values = HomologyHelper.getValuesForHomologueGenes(gene_name, transcripts, gene_set)
      add_triads(ret, gene_set_name, values.keys)
    end
    ret["values"] = values
    add_ret_values(ret, params)
    respond_to do |format|
      format.json { render json: ret, format: :json }
    end
  end

  def transcript
    ret = Hash.new
    puts params.inspect
    gene_set = GeneSet.find_by name: params["gene_set"]
    gene = Gene.find_by name: params["name"], gene_set: gene_set
    compare = Gene.find_by name: params["compare"], gene_set: gene_set if params["compare"]
    ret["gene"] = gene.name
    values = Hash.new
    if compare
      values = getValuesToCompareTranscipts(gene, compare)
      ret["compare"] = params["compare"]
    else
      values = ExpressionValuesHelper.getValuesForHomologuesTranscripts(gene)
      gene_set_name = GeneSet.find(gene.gene_set_id).name
      add_triads(ret, gene_set_name, values.keys)
    end
    ret["values"] = values
    add_ret_values(ret, params)
    respond_to do |format|
      format.json { render json: ret, format: :json }
    end
  end

  def genes
    ret = Hash.new
    values = Hash.new
    genes = []
    genes = session[:genes]
    genes = genes.split(",")
    gene_set = GeneSet.find(session[:gene_set_id])
    genes.each do |g|
      gene, search_by = GenesHelper.findGeneName(g, gene_set)
      values[g] = search_by == "transcript" ?
      ExpressionValuesHelper.getValuesForTranscript(gene) :
      ExpressionValuesHelper.getValuesForTranscripts(GenesHelper.findTranscripts(g, gene_set))
    end
    ret["values"] = values
    add_ret_values(ret, params)
    respond_to do |format|
      format.json { render json: ret }
    end
  end

  def getDefaultSelection
    defSelection = {}
    default_factor_order = DefaultFactorOrder.all
    default_factor_order.each do |factor|
      if factor.selected
        defSelection[factor.name] = false if factor.selected.zero?
        defSelection[factor.name] = true unless factor.selected.zero?
      else
        defSelection[factor.name] = true
      end
    end
    return defSelection
  end

  private

  def add_ret_values(ret, params)
    factorOrder, longFactorName, selectedFactors = ExperimentsHelper.getFactorOrder
    experiments, groups =  ExperimentsHelper.getExperimentGroups
    params["studies"].each do |e|
      selectedFactors["study"][e] = true
    end if params["studies"] and params["studies"].respond_to?("each")

    ret["factorOrder"] = factorOrder
    ret["longFactorName"] = longFactorName

    ret["selectedFactors"] = selectedFactors
    ret["defaultFactorSelection"] = getDefaultSelection
    ret["defaultFactorOrder"] = ExperimentsHelper.getDefaultOrder

    ret["experiments"] = experiments
    ret["groups"] = groups
  end

  # Adding the tern_order and tern values (triads) to the data which enables the ternary plot to be displayed
  def add_triads(ret, gene_set, triads)

    # Adding the tern order
    ret["tern_order"] = ["A", "D", "B"]
    ret["tooltip_order"] = ["A", "B", "D"]

    # Adding data for expression bias
    ret["expression_bias"] = {}
    ExpressionBias.all.each do |eb|
      ret["expression_bias"][eb.name] = eb.expression_bias_values.map { |e| e.max }.sort
    end
    ret["expression_bias_colors"] = {
      :"Azhurnaya" => [
        "#377eb8", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#e41a1c"
      ],
      :"Chinese Spring" => [
        "#377eb8", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#bdbdbd", "#e41a1c"
      ],
    }
    # Adding the tern (ternkey => gene name)
    terns = Hash.new
    triads.each do |triad|
      # Extracting the tern key from the gene name (for IWGSC2.26 & RefSeq tern key is always the letter after the 1st number and for TGACv1 it is the letter aftr the 3rd number)
      # Returns an array of all digits in the gene name
      #TODO: Make this from the database. Use the position column in the gene. 
      first_number = triad.scan(/[[:digit:]]/)
      # Getting the index of the tern key
      if gene_set == "TGACv1"
        tern_key_index = triad.index(first_number[2]) + 1
      else
        tern_key_index = triad.index(first_number[0]) + 1
      end
      # Getting the tern key from its index
      tern_key = triad[tern_key_index]
      allocate_triad_to_tern(tern_key, terns, triad) if ["A", "D", "B"].include?(tern_key)
    end
    ret["tern"] = terns
  end

  # Allocating triads to their corresponding tern (and compare perc_cov with already existing triad allocated to its tern) which prepares data for ternary plot display
  def allocate_triad_to_tern(tern_key, terns, triad)
    if terns[tern_key].nil?
      # puts "\n#{tern_key} doesn't have any value\n"
      terns[tern_key] = triad
    else
      # puts "\n#{tern_key} already HAS a value\n"
      first_triad = Gene.find_by name: terns[tern_key]
      first_homology_pair = HomologyPair.find_by gene_id: first_triad.id
      first_perc_cov = first_homology_pair.perc_cov
      second_triad = Gene.find_by name: triad
      second_homology_pair = HomologyPair.find_by gene_id: second_triad.id
      second_perc_cov = second_homology_pair.perc_cov
      if first_perc_cov < second_perc_cov
        #puts "\n\n\nsecond perc_cov:#{second_perc_cov} > first perc_cov:#{first_perc_cov}\n\n\n"
        terns[tern_key] = triad
      #else
        #puts "\n\n\nsecond perc_cov:#{second_perc_cov} < first perc_cov:#{first_perc_cov}\n\n\n"
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expression_value_params
    params.require(:expression_value).permit(:compare, :experiment_id, :gene_id, 
      :meta_experiment_id, :type_of_value_id, :value)
  end
end
