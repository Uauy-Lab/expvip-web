require 'json'

class ExpressionValuesController < ApplicationController
  before_action :set_expression_value, only: [:show, :edit, :update, :destroy]

  # GET /expression_values
  # GET /expression_values.json
  def index
    @expression_values = ExpressionValue.all
  end

  # GET /expression_values/1
  # GET /expression_values/1.json
  def show
  end

  # GET /expression_values/new
  def new
    @expression_value = ExpressionValue.new
  end

  # GET /expression_values/1/edit
  def edit
  end

  

  # POST /expression_values
  # POST /expression_values.json
  def create
    @expression_value = ExpressionValue.new(expression_value_params)

    respond_to do |format|
      if @expression_value.save
        format.html { redirect_to @expression_value, notice: 'Expression value was successfully created.' }
        format.json { render :show, status: :created, location: @expression_value }
      else
        format.html { render :new }
        format.json { render json: @expression_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expression_values/1
  # PATCH/PUT /expression_values/1.json
  def update
    respond_to do |format|
      if @expression_value.update(expression_value_params)
        format.html { redirect_to @expression_value, notice: 'Expression value was successfully updated.' }
        format.json { render :show, status: :ok, location: @expression_value }
      else
        format.html { render :edit }
        format.json { render json: @expression_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_values/1
  # DELETE /expression_values/1.json
  def destroy
    @expression_value.destroy
    respond_to do |format|
      format.html { redirect_to expression_values_url, notice: 'Expression value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def getFactorOrder
   factorOrder     = Hash.new
   longFactorName  = Hash.new
   selectedFactors = Hash.new

   Study.find_each do |s| 
    factorOrder["study"]     = Hash.new unless factorOrder["study"]
    longFactorName["study"]  = Hash.new unless longFactorName["study"]
    selectedFactors["study"] = Hash.new unless selectedFactors["study"]  
    order = factorOrder["study"] 
    longName = longFactorName["study"]
    selected = selectedFactors["study"] 

    order[s.accession] = s.id
    longName[s.accession] = s.title
    longName[s.accession] = s.accession unless s.title
    selected[s.accession] = false

  end

  Factor.find_each do |f|

    factorOrder[f.factor]     = Hash.new unless factorOrder[f.factor]
    longFactorName[f.factor]  = Hash.new unless longFactorName[f.factor]
    selectedFactors[f.factor] = Hash.new unless selectedFactors[f.factor]  

    order = factorOrder[f.factor] 
    longName = longFactorName[f.factor]
    selected = selectedFactors[f.factor] 

    order[f.name] = f.order
    longName[f.name] = f.description
    selected[f.name] = true
  end
  return [factorOrder, longFactorName, selectedFactors]
end

def getExperimentGroups
  experiments     = Hash.new 
  groups          = Hash.new 
  Experiment.find_each do | g |
    group = Hash.new
    #byebug
    #puts g.inspect
    #Should we use description instead?
    group["name"] = g.accession
    group["description"] = g.accession
    #group["group"] = g.id.to_s
    factors = Hash.new
    g.factors.each { |f| factors[f.factor] = f.name }


    experiments[g.id] = Hash.new 
    exp = experiments[g.id]
    exp["name"]  = g.accession
    #exp["study"] = g.study.
    exp["group"] = g.id.to_s
    factors["study"] = g.study.accession

    #g.experiments.each do |e|  
    #  unless experiments[e.id]
    #    experiments[e.id] = Hash.new 
    #    exp = experiments[e.id]
    #    exp["name"] = e.accession
    #    exp["study"] = e.study_id.to_s
    #    exp["group"] = g.id.to_s
    #    factors["study"] = e.study.accession
    #  end
    #end
    group['factors'] = factors
    groups[g.id] = group
  end
  return [experiments, groups]
end

def getValuesForGene(gene)
  #TODO: Add code to validate for different experiments. 
  values = Hash.new
  client = MongodbHelper.getConnection
  ExpressionValue.where("gene_id = :gene", {gene: gene.id }).each do |ev|  
    type_of_value = ev.type_of_value.name
    values[type_of_value] = Hash.new unless  values[type_of_value]
    tvh = values[type_of_value]
    obj = client[:experiments].find({ :_id => ev.id })
    obj.first.each_pair { |k, val| values[type_of_value][k.to_s] = {experiment:  k, value: val}  unless k == "_id" }
    
  end
  return values
end

def getDefaultOrder 
    #TODO This should be a table in the DB at some point
    defOrder = [
      "study",
      "High level tissue",
      "Tissue",
      "High level age", 
      "Age", 
      "High level stress-disease", 
      "Stress-disease",
      "High level variety",
      "Variety",
      "Intermediate",
      "Intermediate stress"
    ]
    return defOrder
  end

  def getValuesForHomologues(gene)
    values = Hash.new
    values[gene.name] = getValuesForGene(gene)  
    HomologyPair.where("gene_id = :gene", {gene: gene.id}).each do |h|
      hom = h.homology 
      HomologyPair.where("homology = :hom", {hom: hom}).each do |h2|
        if h2.gene.gene_set_id == gene.gene_set_id
          values[h2.gene.name] = getValuesForGene(h2.gene) unless h2.gene == gene
        end
      end
    end
  return values
end

def getValuesToCompare(gene, compare)
  values = Hash.new
  values[gene.name]    = getValuesForGene(gene)
  values[compare.name] = getValuesForGene(compare) 
  return values
end


def gene
    #puts @gene_id
   #ret = Hash.new
    #ret["Hello"] = params
    #ret = ExpressionValue.find_expression_for_gene(params["gene_id"])
    
    ret = Hash.new 
    gene = Gene.find params["gene_id"]
    compare = Gene.find_by name: params["compare"] if params["compare"]
    ret['gene'] = gene.name

    
    values = Hash.new
    
    if compare  
      values = getValuesToCompare(gene, compare)
      ret["compare"] = params["compare"]
    else
      values = getValuesForHomologues(gene)            
      gene_set_name = GeneSet.find(gene.gene_set_id).name      
      add_triads(ret, gene_set_name, values.keys)
    end
    ret["values"] = values
    add_ret_values(ret, params)
   
    respond_to do |format|
      format.json {render json: ret, format: :json}
    end

  end


  def transcript
    
    puts "TRANSCRIPT!!!"
    puts params.inspect
    puts "Gene set: '#{params[:name]}'"
    ret = Hash.new 

    gene_set = GeneSet.find_by name: params["gene_set"]
    gene     = Gene.find_by    name: params["name"],    gene_set: gene_set
    compare  = Gene.find_by    name: params["compare"], gene_set: gene_set if params["compare"]
    ret['gene'] = gene.name

    values = Hash.new
    if compare  
      values = getValuesToCompare(gene, compare)
      ret["compare"] = params["compare"]
    else
      values = getValuesForHomologues(gene,)            
      gene_set_name = GeneSet.find(gene.gene_set_id).name      
      add_triads(ret, gene_set_name, values.keys)
    end
    ret["values"] = values
    add_ret_values(ret, params)

    respond_to do |format|
      format.json {render json: ret, format: :json}
    end

  end

  def genes

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger.level  = 1
    Rails.logger.info "genes"
    Rails.logger.info session[:genes]
    ret = Hash.new 
    values = Hash.new
    genes = []
    useIDs = false
    if  session[:genes] 
      useIDs = true
      genes = session[:genes] 
    end
    genes = params["genes"] if params["genes"] 
    genes = genes.split(',')
    genes. each do |g|
      gene = false
      if useIDs 
        gene = Gene.find(g.to_i)
      else
        gene = Gene.find_by(:name=>g)
        gene = Gene.find_by(:gene=>g) unless  gene
      end
      values[gene.name] = getValuesForGene(gene)  if gene
    end

    ret["values"] = values
    add_ret_values(ret, params)

    ActiveRecord::Base.logger = old_logger
    respond_to do |format|
      format.json {render json: ret}
    end

  end

  def getDefaultSelection
    #TODO: This should be also dynamic. 
    defSelection = {
    "Age"=> false,
    "High level stress-disease"=> true,
    "High level age"=> true,
    "High level tissue"=>true,
    "High level variety"=>true,
    "Stress-disease"=>false,
    "study"=>false,
    "Tissue" => false,
    "Intermediate" => false,
    "Intermediate stress" => false
  }
  return defSelection
end

  private

    def add_ret_values(ret, params)
      factorOrder, longFactorName, selectedFactors = getFactorOrder 
      experiments, groups = getExperimentGroups
      params["studies"].each { |e| selectedFactors["study"][e] = true } if  params["studies"]  and params["studies"].respond_to?('each')

      ret["factorOrder"]= factorOrder
      ret["longFactorName"]= longFactorName
      
      ret["selectedFactors"]= selectedFactors
      ret["defaultFactorSelection"] = getDefaultSelection
      ret["defaultFactorOrder"] = getDefaultOrder
      
      ret["experiments"] = experiments
      ret["groups"] = groups

    end

    # Adding the tern_order and tern values (triads) to the data which enables the ternary plot to be displayed
    def add_triads(ret, gene_set, triads)

      # Adding the tern order
      ret["tern_order"] = ["A", "D", "B"]

      # Adding the tern (ternkey => gene name)
      terns = Hash.new    

      triads.each do |triad|

        # Extracting the tern key from the gene name (for IWGSC2.26 & RefSeq tern key is always the letter after the 1st number and for TGACv1 it is the letter aftr the 3rd number)
        # Returns an array of all digits in the gene name
        first_number = triad.scan(/[[:digit:]]/)

        # Getting the index of the tern key
        if gene_set == "TGACv1"
          tern_key_index = triad.index(first_number[2]) + 1
        else
          tern_key_index = triad.index(first_number[0]) + 1
        end      

        # Getting the tern key from its index
        tern_key = triad[tern_key_index]        

        case tern_key
        when "A"          

          allocate_triad_to_tern("A", terns, triad)

        when "B"
          
          allocate_triad_to_tern("B", terns, triad)
                    
        when "D"
        
          allocate_triad_to_tern("D", terns, triad)
                    
        else
          puts "\n\n\nCouldn't find a tern key :(\n\n\n" 
        end     

      end

      ret["tern"] = terns
      
    end  

    # Allocating triads to their corresponding tern (and compare perc_cov with already existing triad allocated to its tern) which prepares data for ternary plot display
    def allocate_triad_to_tern(tern_key, terns, triad)    

      if terns[tern_key].nil?
        puts "\n#{tern_key} doesn't have any value\n"
        terns[tern_key] = triad
      else
        puts "\n#{tern_key} already HAS a value\n"

        first_triad = Gene.find_by name: terns[tern_key]
        first_homology_pair = HomologyPair.find_by gene_id: first_triad.id
        first_perc_cov = first_homology_pair.perc_cov
        second_triad = Gene.find_by name: triad          
        second_homology_pair = HomologyPair.find_by gene_id: second_triad.id
        second_perc_cov = second_homology_pair.perc_cov

        if first_perc_cov < second_perc_cov
          puts "\n\n\nsecond perc_cov:#{second_perc_cov} > first perc_cov:#{first_perc_cov}\n\n\n"
          terns[tern_key] = triad
        else
          puts "\n\n\nsecond perc_cov:#{second_perc_cov} < first perc_cov:#{first_perc_cov}\n\n\n"
        end                    
      end

    end

    # Use callbacks to share common setup or constraints between actions.
    def set_expression_value
      @expression_value = ExpressionValue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expression_value_params
      params.require(:expression_value).permit(:compare, 
        :experiment_id, 
        :gene_id, 
        :meta_experiment_id, 
        :type_of_value_id, 
        :value)
    end

  end
