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
    ExperimentGroup.find_each do | g |
      group = Hash.new
      #Should we use description instead?
      group["name"] = g.name
      group["description"] = g.name
      factors = Hash.new
      g.factors.each { |f| factors[f.factor] = f.name }
      

      g.experiments.each do |e|  
        unless experiments[e.id]
          experiments[e.id] = Hash.new 
          exp = experiments[e.id]
          exp["name"] = e.accession
          exp["study"] = e.study_id.to_s
          exp["group"] = g.id.to_s
          factors["study"] = e.study.accession
        end
      end
      group['factors'] = factors
      groups[g.id] = group
    end
    return [experiments, groups]
  end

  def getValuesForGene(gene)
    values = Hash.new
    ExpressionValue.where("gene_id = :gene", {gene: gene.id }).each do |ev|  
      type_of_value = ev.type_of_value.name
      values[type_of_value] = Hash.new unless  values[type_of_value]
      tvh = values[type_of_value]

      tvh[ev.experiment.id] = { experiment:  ev.experiment.id.to_s , value: ev.value}

    end
    return values
  end

  def inchworm
    #puts @genes

    ret = Hash.new
#    ret["genes"] = params["genes"].split(",")
    genes = params["genes"].split(",")
    ret["data"] = Hash.new
    ret["data"]["nodes"] = Hash.new
    nodes =  ret["data"]["nodes"]
    ret["data"]["Missing"] = Array.new
#    ret["data"]["feature_names"] = Array.new
    ret["metadata"] = Hash.new
    ret["metadata"]["feature_names"] = ["Gene"]
    ret["metadata"]["nodes"] = Hash.new

    experiments, groups = getExperimentGroups
    factorOrder, longFactorName, selectedFactors = getFactorOrder
    experimentIds = experiments.keys
    factors = factorOrder.keys
    
    ret["column_metadata"] = Hash.new
    ret["column_metadata"]["features"] = Array.new
    ret["column_metadata"]["feature_names"] =factors 
    
    #studies = Array.new
    factorValues = factors.map { |f| Array.new }


   
    experimentIds.map do |i| 
      group = experiments[i]["group"]
  
      g = groups[group.to_i]
      fact =  g["factors"]
    
      factors.each_with_index  { |f, j| factorValues[j] <<  g["factors"][f] }
      
    #  studies <<  groups[experiments[i]["group"]]["factors"]
      
    end  
  
    ret["column_metadata"]["features"] = factorValues

    ret["data"]["feature_names"]  = experimentIds.map { |i| experiments[i]["name"] }
    genes.each do |g|  
      nodes[g] = Hash.new
      gene = Gene.find_by(name: g)
      if gene
        valuesForGene = getValuesForGene gene
        tpm =  valuesForGene["tpm"]
        vals = Array.new
        experimentIds.each { |k|  vals << tpm[k][:value]}
        nodes[g]["features"] = vals
        nodes[g]["count"] = 1
        nodes[g]["distance"] = 0
        nodes[g]["objects"] =  [gene.name]

        ret["metadata"]["nodes"][g] = [g]

      else
        ret["data"]["Missing"] <<  g
      end
    end


    respond_to do |format|
      format.json {render json: ret}
    end
  end

  #TODO: Add this to the database. 
  def getDefaultSelection 
       defSelection = {
        "Age"=> false, 
        "High level Stress-disease"=> true, 
        "High level age"=> true, 
        "High level tissue"=>true,
        "High level variety"=>true,
        "Stress-disease"=>false,
        "study"=>false,
        "Tissue" => false,
        "Variety" => false
       }
       return defSelection
  end

  def getDefaultOrder 
    #This should be a table in the DB at some point
    defOrder = [
        "study",
        "High level tissue",
        "Tissue",
        "High level age", 
        "Age", 
        "High level Stress-disease", 
        "Stress-disease",
        "High level variety",
        "Variety"
    ]
    return defOrder
  end

  def getValuesForHomologues(gene)

    values = Hash.new
    Homology.where("Gene_id = :gene", {gene: gene.id}).each do |h|
       values[h.A.name] = getValuesForGene(h.A) if h.A
       values[h.B.name] = getValuesForGene(h.B) if h.B
       values[h.D.name] = getValuesForGene(h.D) if h.D
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

    factorOrder, longFactorName, selectedFactors = getFactorOrder 
    experiments, groups = getExperimentGroups
    values = Hash.new
    params["studies"].each { |e| selectedFactors["study"][e] = true } if  params["studies"]  and params["studies"].respond_to?('each')

    if compare
      
      values = getValuesToCompare(gene, compare)
      ret["compare"] = params["compare"]
    else
      values = getValuesForHomologues(gene)
    end

    ret["gene"]= gene.name
    ret["factorOrder"]= factorOrder
    ret["longFactorName"]= longFactorName
    
    ret["selectedFactors"]= selectedFactors
    ret["defaultFactorSelection"] = getDefaultSelection
    ret["defaultFactorOrder"] = getDefaultOrder
    
    ret["experiments"] = experiments
    ret["groups"] = groups
    ret["values"] = values

    respond_to do |format|
      format.json {render json: ret}
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expression_value
      @expression_value = ExpressionValue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expression_value_params
      params.require(:expression_value).permit(:compare, :experiment_id, :gene_id, :meta_experiment_id, :type_of_value_id, :value)
    end
end
