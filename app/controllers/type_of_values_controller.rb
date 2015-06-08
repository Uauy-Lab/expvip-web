class TypeOfValuesController < ApplicationController
  before_action :set_type_of_value, only: [:show, :edit, :update, :destroy]

  # GET /type_of_values
  # GET /type_of_values.json
  def index
    @type_of_values = TypeOfValue.all
  end

  # GET /type_of_values/1
  # GET /type_of_values/1.json
  def show
  end

  # GET /type_of_values/new
  def new
    @type_of_value = TypeOfValue.new
  end

  # GET /type_of_values/1/edit
  def edit
  end

  # POST /type_of_values
  # POST /type_of_values.json
  def create
    @type_of_value = TypeOfValue.new(type_of_value_params)

    respond_to do |format|
      if @type_of_value.save
        format.html { redirect_to @type_of_value, notice: 'Type of value was successfully created.' }
        format.json { render :show, status: :created, location: @type_of_value }
      else
        format.html { render :new }
        format.json { render json: @type_of_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /type_of_values/1
  # PATCH/PUT /type_of_values/1.json
  def update
    respond_to do |format|
      if @type_of_value.update(type_of_value_params)
        format.html { redirect_to @type_of_value, notice: 'Type of value was successfully updated.' }
        format.json { render :show, status: :ok, location: @type_of_value }
      else
        format.html { render :edit }
        format.json { render json: @type_of_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /type_of_values/1
  # DELETE /type_of_values/1.json
  def destroy
    @type_of_value.destroy
    respond_to do |format|
      format.html { redirect_to type_of_values_url, notice: 'Type of value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_type_of_value
      @type_of_value = TypeOfValue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def type_of_value_params
      params.require(:type_of_value).permit(:name, :description)
    end
end
