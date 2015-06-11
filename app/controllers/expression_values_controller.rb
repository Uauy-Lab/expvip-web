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

  def gene
    #puts @gene_id
    #ret = Hash.new
    #ret["Hello"] = params
    ret = ExpressionValue.find_expression_for_gene(params["gene_id"])
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
      params.require(:expression_value).permit(:experiment_id, :gene_id, :meta_experiment_id, :type_of_value_id, :value)
    end
end
