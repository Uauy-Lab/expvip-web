class TissuesController < ApplicationController
  before_action :set_tissue, only: [:show, :edit, :update, :destroy]

  # GET /tissues
  # GET /tissues.json
  def index
    @tissues = Tissue.all
  end

  # GET /tissues/1
  # GET /tissues/1.json
  def show
  end

  # GET /tissues/new
  def new
    @tissue = Tissue.new
  end

  # GET /tissues/1/edit
  def edit
  end

  # POST /tissues
  # POST /tissues.json
  def create
    @tissue = Tissue.new(tissue_params)

    respond_to do |format|
      if @tissue.save
        format.html { redirect_to @tissue, notice: 'Tissue was successfully created.' }
        format.json { render :show, status: :created, location: @tissue }
      else
        format.html { render :new }
        format.json { render json: @tissue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tissues/1
  # PATCH/PUT /tissues/1.json
  def update
    respond_to do |format|
      if @tissue.update(tissue_params)
        format.html { redirect_to @tissue, notice: 'Tissue was successfully updated.' }
        format.json { render :show, status: :ok, location: @tissue }
      else
        format.html { render :edit }
        format.json { render json: @tissue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tissues/1
  # DELETE /tissues/1.json
  def destroy
    @tissue.destroy
    respond_to do |format|
      format.html { redirect_to tissues_url, notice: 'Tissue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tissue
      @tissue = Tissue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tissue_params
      params.require(:tissue).permit(:name, :description)
    end
end
