class GenesController < ApplicationController

  require 'digest'  

  before_action :set_gene, only: [:show, :edit, :update, :destroy]

  def getGeneIds(genes)
    ids = Array.new
    missing = Array.new
    gene_set = GeneSet.find(session[:gene_set_id])    
    genes.each do |g|  
      gene = Gene.find_by(:name=>g, :gene_set_id=>gene_set.id)
      gene = Gene.find_by(:gene=>g, :gene_set_id=>gene_set.id) unless  gene
      if gene
        ids << gene.id
      else
        missing << g
      end
    end
    raise "Genes not found: #{missing.join(",")}" if missing.size != 0
    return ids
  end

  #
  def forwardHeatmap
    genes = params[:genes_heatmap].split(/[,\s]+/).map { |e| e.strip }
    raise "Please select less than 500 genes" if genes.size > 500
    ids = getGeneIds(genes)
    raise "Plese select some genes for the heatmap" if ids.size == 0
    session[:genes] = ids.join(',')    
    redirect_to action: "heatmap"
  end

  def forwardCommon
    gene_name = nil
    gene_name = params[:gene]
    gene_name = params[:query] if params[:query]
    @gene_set = GeneSet.find(params[:gene_set_selector]) if params[:gene_set_selector]
    @gene_set = GeneSet.find_by(:name => params[:gene_set]) if params[:gene_set]    
    session[:heatmap] = false
    @gene, @search_by = findGeneName gene_name, @gene_set 
    session[:gene] = @search_by == "gene" ? @gene.gene : @gene.name 
    session[:search_by] = @search_by
    session[:gene_set_id] = @gene_set.id
  end

  def forwardSearch
    forwardCommon    
    redirect_to  action: "show", 
      search_by: @search_by, 
      gene: session[:gene], 
      gene_set: @gene_set.name
  end

  def forwardCompare
    forwardCommon
    @compare, @search_by_compare = findGeneName params[:compare], @gene_set

    unless @search_by == @search_by_compare
      flash[:error] =  "Can't compare gene vs transcript" 
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
      return
    end
    redirect_to  action: "show", 
      search_by: @search_by, 
      gene: session[:gene], 
      gene_set: @gene_set.name,
      compare:  @compare.name  
  end

  def findGeneName(gene_name, gene_set)
    begin 
      gene = Gene.find_by(:name=>gene_name, :gene_set_id=>gene_set.id)      
      gene = Gene.find_by(:gene=>gene_name, :gene_set_id=>gene_set.id) unless  gene
    rescue    
      raise "\n\n\nGene not found: #{gene_name} for #{gene_set.name}\n\n\n" unless gene      
    end    
    return [gene,  gene_name == gene.gene ? "gene": "transcript" ]  
  end

  # GET /genes
  # GET /genes.json
  def forward
    session[:studies] = params[:studies] if  params[:studies]     
    begin
      case params[:submit] 
      when "Heatmap"
        forwardHeatmap 
      when "Search"
        forwardSearch
      when "Compare"
        forwardCompare
      else
        raise "Unknow redirect: #{params[:submit]}"
      end
    rescue Exception => e
      flash[:error] = e
      puts e
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
      return
    end
end

  def autocomplete
    gene_set_id = session[:gene_set_id] 
    @genes = Gene.order(:name).where("name LIKE ? and gene_set_id = ?", "%#{params[:term]}%", gene_set_id).limit(20)

    respond_to do |format|
      format.html
      format.json { 
        render json: [@genes.map(&:gene).uniq, @genes.map(&:transcript) ].flatten
      }
    end
  end

  def heatmap
    session[:studies] = params[:studies] if  params[:studies] 
    studies = session[:studies]
    genes = []
    genes = session[:genes] if  session[:genes] 
    genes = params[:genes] if params[:genes]
    session[:genes] = params[:genes] if params[:genes]
    
    
    #This acts as a flag for share action
    session[:heatmap] = true
    
    # If parameters passed cnotain settings (it's a shared link)
    if params[:settings]
      @client = MongodbHelper.getConnection unless @client    
      data = @client[:share].find({'hash' =>  params[:settings]}).first
      @settings = data[:settings]
      gene_set_name = data[:gene_set]
      @gene_set_id = GeneSet.find_by(:name=>gene_set_name)
      session[:gene_set_id] = @gene_set_id.id            
      settingsObj = JSON.parse @settings
      studies = settingsObj['study']           
    end 
    
    @args = {studies: studies }.to_query
    respond_to do |format|
      format.html { render :heatmap }
    end
  end

  # GET /genes/1
  # GET /genes/1.json
  def show 
    #Use TRIAE_CS42_2BL_TGACv1_130848_AA0418720 as it has multiple transcripts
    studies = session[:studies]    
    compare = ""
    alert = ""
    
    gene = {
      name: params[:gene],
      gene: params[:gene], 
      search_by: params[:search_by]
    }


    # session[:gene] = @gene.name
    # If parameters passed contain compare
    if params[:compare]

      #@compare =  Gene.find_by(:name=>params[:compare])
      #@compare =  Gene.find_by(:gene=>params[:compare]) unless  @compare
      compare = params[:compare]
    end    
    
    # If parameters passed contain settings (it's a shared link)
    if params[:settings]
      @client = MongodbHelper.getConnection unless @client    
      data = @client[:share].find({'hash' =>  params[:settings]}).first
      @settings = data[:settings]
      gene_set_name = data[:gene_set]
      @gene_set_id = GeneSet.find_by(:name=>gene_set_name)
      session[:gene_set_id] = @gene_set_id.id            
      settingsObj = JSON.parse @settings
      studies = settingsObj['study']           
    end   
    @gene = OpenStruct.new(gene)
    
    @args = {studies: studies, compare: compare, gene_set: params[:gene_set]  }.to_query
    #studies.each { |e|  @studies += "studies[]=#{e}\&" }`
  end  

  def share 
    # Hash the settings 
    sha1 = Digest::SHA1.new
    sha1 << params[:settings]
    hashedSettings = sha1.hexdigest        
    

    # Get the gene
    if !session[:heatmap]      
      gene_set = GeneSet.find(session[:gene_set_id])    
      if params[:gene]
        gene_name = params[:gene]       
        session[:gene] = gene_name      
      else
        gene_name = session[:gene]
      end                     
      @gene = findGeneName gene_name, gene_set                        
    else        
      gene_set = GeneSet.find(session[:gene_set_id])            
    end

    # Store the settings
    @client = MongodbHelper.getConnection unless @client            
    @client[:share].insert_one({:gene_set => gene_set.name, :settings => params[:settings], :hash => hashedSettings}) if @client[:share].find({'hash' => hashedSettings}).count == 0                                   
        
    
    if params[:compare]      
      response = request.base_url + "/" + params[:controller].to_s + "/"  + @gene.id.to_s + "?" + {compare: params[:compare]}.to_query + "&" + {settings: hashedSettings}.to_query
    elsif session[:heatmap]
      response = request.base_url + "/" + params[:controller].to_s + "/heatmap" + "?" + {genes: session[:genes]}.to_query + "&" + {settings: hashedSettings}.to_query
    else
      response = request.base_url + "/" + params[:controller].to_s + "/"  + @gene.id.to_s + "?" + {settings: hashedSettings}.to_query
    end        
    
    respond_to do |format|
      format.json { render json: {"value" => response}}      
    end
    
  end

  def set_studies_session
    session[:studies] = JSON.parse params[:studies]    
  end
  
  # DELETE /genes/1
  # DELETE /genes/1.json
  #def destroy
    #@gene.destroy
  #  respond_to do |format|
      #format.html { redirect_to genes_url, notice: 'Gene was successfully destroyed.' }
      #format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gene
      @gene = Gene.find(params[:id]) if numeric? params[:id]
      @gene = Gene.find_by(:name=>params[:gene]) unless @gene
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gene_params
      params.require(:gene).permit(:name,:studies, :cdna, :possition, :gene, :transcript)
    end

    def numeric?(string)
    # `!!` converts parsed number to `true`
    !!Kernel.Float(string) 
  rescue TypeError, ArgumentError
    false
  end
end
