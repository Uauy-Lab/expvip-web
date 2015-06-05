class VarietiesController < ApplicationController
  before_action :set_variety, only: [:show, :edit, :update, :destroy]

  # GET /varieties
  # GET /varieties.json
  def index
    @varieties = Variety.all
  end

  # GET /varieties/1
  # GET /varieties/1.json
  def show
  end

  # GET /varieties/new
  def new
    @variety = Variety.new
  end

  # GET /varieties/1/edit
  def edit
  end

  # POST /varieties
  # POST /varieties.json
  def create
    @variety = Variety.new(variety_params)

    respond_to do |format|
      if @variety.save
        format.html { redirect_to @variety, notice: 'Variety was successfully created.' }
        format.json { render :show, status: :created, location: @variety }
      else
        format.html { render :new }
        format.json { render json: @variety.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /varieties/1
  # PATCH/PUT /varieties/1.json
  def update
    respond_to do |format|
      if @variety.update(variety_params)
        format.html { redirect_to @variety, notice: 'Variety was successfully updated.' }
        format.json { render :show, status: :ok, location: @variety }
      else
        format.html { render :edit }
        format.json { render json: @variety.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /varieties/1
  # DELETE /varieties/1.json
  def destroy
    @variety.destroy
    respond_to do |format|
      format.html { redirect_to varieties_url, notice: 'Variety was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_variety
      @variety = Variety.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def variety_params
      params.require(:variety).permit(:name, :description, :url)
    end
end
