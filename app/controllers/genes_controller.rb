class GenesController < ApplicationController
  before_action :set_gene, only: [:show, :edit, :update, :destroy]

  # GET /genes
  # GET /genes.json
  def index
    
    gene_name = nil
    gene_name = params[:gene]
    gene_name = params[:query] if params[:query]

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
    elsif params[:genes_heatmap]
     
       redirect_to action: "heatmap", genes_heatmap: params[:genes_heatmap]      
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
    homs = Homology.where("Gene_id = :gene", {gene: @gene.id}).first
    hom_counts = homs.total
    if hom_counts != 3
      alert += "#{@gene.name} has #{hom_counts - 1} homoeologues \n"
    end
    if params[:compare]
      @compare =  Gene.find_by(:name=>params[:compare])
      @compare =  Gene.find_by(:gene=>params[:compare]) unless  @compare
      hom_counts = Homology.where("Gene_id = :gene", {gene: @compare.id}).count
      if hom_counts != 3
        alert += "#{@compare.name} has #{hom_counts - 1} homoeologues\n"
      end
      compare = @compare.transcript
    end
  
    if alert.size > 0
       flash[:info] = "#{alert}"
    end

    @args = {studies: studies, compare: compare }.to_query
    #studies.each { |e|  @studies += "studies[]=#{e}\&" }
  end

  # GET /genes/new
  def new
    @gene = Gene.new
  end

  # GET /genes/1/edit
  def edit
  end

  # POST /genes
  # POST /genes.json
  def create
    @gene = Gene.new(gene_params)

    respond_to do |format|
      if @gene.save
        format.html { redirect_to @gene, notice: 'Gene was successfully created.' }
        format.json { render :show, status: :created, location: @gene }
      else
        format.html { render :new }
        format.json { render json: @gene.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /genes/1
  # PATCH/PUT /genes/1.json
  def update
    respond_to do |format|
      if @gene.update(gene_params)
        format.html { redirect_to @gene, notice: 'Gene was successfully updated.' }
        format.json { render :show, status: :ok, location: @gene }
      else
        format.html { render :edit }
        format.json { render json: @gene.errors, status: :unprocessable_entity }
      end
    end
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
