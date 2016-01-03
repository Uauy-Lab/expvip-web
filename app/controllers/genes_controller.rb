class GenesController < ApplicationController
  before_action :set_gene, only: [:show, :edit, :update, :destroy]

  # GET /genes
  # GET /genes.json
  def index
    puts "Index: #{params}"
    gene_name = nil
    gene_name = params[:gene]
    gene_name = params[:query] if params[:query]
    if params[:genes_heatmap]
       genes = params[:genes_heatmap].split(",")
       redirect_to action: "heatmap",  studies: params[:studies],  genes: genes
       return   
    end
   if params[:compare]
      @compare =  Gene.find_by(:name=>params[:compare])
      @compare =  Gene.find_by(:gene=>params[:compare]) unless  @compare
   end
    
    if gene_name
     # logger.debug params
      @gene =  Gene.find_by(:name=>gene_name)
      @gene = Gene.find_by(:gene=>gene_name) unless  @gene
      unless @gene
        flash[:error] = "Gene not found: #{gene_name}"
        redirect_to :back
        return    
      end
      #"commit" "Compare" 
      #TODO: Show error message on the way back.

      session[:gene] = @gene.name
      session[:studies] = params[:studies] if  params[:studies] 

      if params[:commit] == "Compare"

        unless @compare
          flash[:error] = "Gene to compare not found: #{params[:compare]}"
          redirect_to :back
          return
        end    
        redirect_to  action: "show", id: @gene.id, studies: params[:studies], compare:  @compare.name 
      else
        redirect_to  action: "show", id: @gene.id, studies: params[:studies]
      end
    else
       @genes = Gene.find(:all, :order => "id desc", :limit => 10) #TODO: make this in a way you can page. 
    end
      
 #   format.html { redirect_to action: :show, id: @gene.id }
  end

  def autocomplete
    #puts "In autocomplete!"
    @genes = Gene.order(:name).where("name LIKE ?", "%#{params[:term]}%").limit(20)

    respond_to do |format|
      format.html
      format.json { 
        render json: @genes.map(&:name)
      }
    end
  end

  def heatmap
    session[:studies] = params[:studies] if  params[:studies] 
    studies = session[:studies]
    genes = params[:genes]

    @args = {studies: studies, genes: genes }.to_query
    respond_to do |format|
      format.html { render :heatmap }
    end
  end

  # GET /genes/1
  # GET /genes/1.json
  def show
    session[:studies] = params[:studies] if  params[:studies] 
    studies = session[:studies]
    compare = ""
    alert = ""
   
    if params[:compare]
      @compare =  Gene.find_by(:name=>params[:compare])
      @compare =  Gene.find_by(:gene=>params[:compare]) unless  @compare
      compare = @compare.transcript
    end
  
    @args = {studies: studies, compare: compare }.to_query
    #studies.each { |e|  @studies += "studies[]=#{e}\&" }
  end

  # GET /genes/new
  def new
  end

  # GET /genes/1/edit
  def edit
  end

  # POST /genes
  # POST /genes.json
  def create
  end

  # PATCH/PUT /genes/1
  # PATCH/PUT /genes/1.json
  def update
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
