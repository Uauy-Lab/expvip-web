class MetaExperimentsController < ApplicationController
  before_action :set_meta_experiment, only: [:show, :edit, :update, :destroy]

  # GET /meta_experiments
  # GET /meta_experiments.json
  def index
    @meta_experiments = MetaExperiment.all
  end

  # GET /meta_experiments/1
  # GET /meta_experiments/1.json
  def show
  end

  # GET /meta_experiments/new
  def new
    @meta_experiment = MetaExperiment.new
  end

  # GET /meta_experiments/1/edit
  def edit
  end

  # POST /meta_experiments
  # POST /meta_experiments.json
  def create
    @meta_experiment = MetaExperiment.new(meta_experiment_params)

    respond_to do |format|
      if @meta_experiment.save
        format.html { redirect_to @meta_experiment, notice: 'Meta experiment was successfully created.' }
        format.json { render :show, status: :created, location: @meta_experiment }
      else
        format.html { render :new }
        format.json { render json: @meta_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meta_experiments/1
  # PATCH/PUT /meta_experiments/1.json
  def update
    respond_to do |format|
      if @meta_experiment.update(meta_experiment_params)
        format.html { redirect_to @meta_experiment, notice: 'Meta experiment was successfully updated.' }
        format.json { render :show, status: :ok, location: @meta_experiment }
      else
        format.html { render :edit }
        format.json { render json: @meta_experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meta_experiments/1
  # DELETE /meta_experiments/1.json
  def destroy
    @meta_experiment.destroy
    respond_to do |format|
      format.html { redirect_to meta_experiments_url, notice: 'Meta experiment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meta_experiment
      @meta_experiment = MetaExperiment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def meta_experiment_params
      params.require(:meta_experiment).permit(:name, :description, :gene_set_id)
    end
end
