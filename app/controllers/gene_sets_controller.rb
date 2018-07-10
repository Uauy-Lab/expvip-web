class GeneSetsController < ApplicationController
  before_action :set_gene_set, only: [:show, :edit, :update, :destroy]

  # GET /gene_sets
  # GET /gene_sets.json
  def index
    @gene_sets = GeneSet.all
  end

  # GET /gene_sets/1
  # GET /gene_sets/1.json
  def show
  end

  # GET /gene_sets/new
  def new
    @gene_set = GeneSet.new
  end

  # GET /gene_sets/1/edit
  def edit
  end

  # POST /gene_sets
  # POST /gene_sets.json
  def create
    @gene_set = GeneSet.new(gene_set_params)

    respond_to do |format|
      if @gene_set.save
        format.html { redirect_to @gene_set, notice: 'Gene set was successfully created.' }
        format.json { render :show, status: :created, location: @gene_set }
      else
        format.html { render :new }
        format.json { render json: @gene_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gene_sets/1
  # PATCH/PUT /gene_sets/1.json
  def update
    respond_to do |format|
      if @gene_set.update(gene_set_params)
        format.html { redirect_to @gene_set, notice: 'Gene set was successfully updated.' }
        format.json { render :show, status: :ok, location: @gene_set }
      else
        format.html { render :edit }
        format.json { render json: @gene_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gene_sets/1
  # DELETE /gene_sets/1.json
  def destroy
    @gene_set.destroy
    respond_to do |format|
      format.html { redirect_to gene_sets_url, notice: 'Gene set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_gene_set_session
    @gene_set = GeneSet.find(params[:gene_set_selector])
    session[:gene_set_id] = @gene_set.id if @gene_set    
    
    respond_to do |format|      
      format.html
      format.json { 
        render json: {"value" => @gene_set.name}
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gene_set
      @gene_set = GeneSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gene_set_params
      params.require(:gene_set).permit(:name, :description, :gene_set_selector)
    end
end
