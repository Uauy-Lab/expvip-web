class ExperimentGroupsController < ApplicationController
  before_action :set_experiment_group, only: [:show, :edit, :update, :destroy]

  # GET /experiment_groups
  # GET /experiment_groups.json
  def index
    @experiment_groups = ExperimentGroup.all
  end

  # GET /experiment_groups/1
  # GET /experiment_groups/1.json
  def show
  end

  # GET /experiment_groups/new
  def new
    @experiment_group = ExperimentGroup.new
  end

  # GET /experiment_groups/1/edit
  def edit
  end

  # POST /experiment_groups
  # POST /experiment_groups.json
  def create
    @experiment_group = ExperimentGroup.new(experiment_group_params)

    respond_to do |format|
      if @experiment_group.save
        format.html { redirect_to @experiment_group, notice: 'Experiment group was successfully created.' }
        format.json { render :show, status: :created, location: @experiment_group }
      else
        format.html { render :new }
        format.json { render json: @experiment_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /experiment_groups/1
  # PATCH/PUT /experiment_groups/1.json
  def update
    respond_to do |format|
      if @experiment_group.update(experiment_group_params)
        format.html { redirect_to @experiment_group, notice: 'Experiment group was successfully updated.' }
        format.json { render :show, status: :ok, location: @experiment_group }
      else
        format.html { render :edit }
        format.json { render json: @experiment_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiment_groups/1
  # DELETE /experiment_groups/1.json
  def destroy
    @experiment_group.destroy
    respond_to do |format|
      format.html { redirect_to experiment_groups_url, notice: 'Experiment group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_experiment_group
      @experiment_group = ExperimentGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def experiment_group_params
      params.require(:experiment_group).permit(:name, :description)
    end
end
