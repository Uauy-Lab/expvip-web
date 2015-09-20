class GenesController < ApplicationController
  before_action :set_gene, only: [:show, :edit, :update, :destroy]

  # GET /genes
  # GET /genes.json
  def index
    
    gene_name = nil
    gene_name = params[:gene]
    gene_name = params[:query] if params[:query]

    if gene_name
     # logger.debug params
      @gene =  Gene.find_by(:name=>gene_name)
      #TODO: Show error message on the way back. 
      session[:gene] = gene_name
      session[:studies] = params[:studies]
      redirect_to :back and return unless @gene 
      redirect_to  action: "show", id: @gene.id, studies: params[:studies], compare: params[:compare]
    else
      @genes = Gene.all
    end
      
 #   format.html { redirect_to action: :show, id: @gene.id }
  end

  def autocomplete
    #puts "In autocomplete!"
    @genes = Gene.order(:name).where("name LIKE ?", "%#{params[:term]}%")
    puts @genes
    respond_to do |format|
      format.html
      format.json { 
        render json: @genes.map(&:name)
      }
    end
  end

  # GET /genes/1
  # GET /genes/1.json
  def show
    studies = params[:studies]
    @args = {studies: studies, compare: params[:compare] }.to_query.html_safe
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
  def destroy
    @gene.destroy
    respond_to do |format|
      format.html { redirect_to genes_url, notice: 'Gene was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

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
