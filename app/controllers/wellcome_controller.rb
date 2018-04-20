class WellcomeController < ApplicationController
  def default
    @studies = Study.all  	         
    @gene_example_1 = {}


    if params[:gene_set_selector]
      # @gene_example_1[] = Gene.where(gene_set_id: params[:gene_set_selector]).first(2) 
      @gene_example_1[:search] = Gene.where(gene_set_id: params[:gene_set_selector]).first(1) 
      @gene_example_1[:compare] = Gene.where(gene_set_id: params[:gene_set_selector]).first(1) 
      @gene_example_1[:heatmap] = Gene.where(gene_set_id: params[:gene_set_selector]).first(20)

      # @example[:search] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'search')
      # @example[:compare] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'compare')
      # @example[:heatmap] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'heatmap')

    elsif session[:gene_set_id]
      # @gene_example_1 = Gene.where(gene_set_id: session[:gene_set_id]).first(2) 
      @gene_example_1[:search] = Gene.where(gene_set_id: session[:gene_set_id]).first(1) 
      @gene_example_1[:compare] = Gene.where(gene_set_id: session[:gene_set_id]).first(1) 
      @gene_example_1[:heatmap] = Gene.where(gene_set_id: session[:gene_set_id]).first(20)

      # @example[:search] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'search')
      # @example[:compare] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'compare')
      # @example[:heatmap] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'heatmap')
    else
      # @gene_example_1 = Gene.where(gene_set_id: 1).first(2) 
      @gene_example_1[:search] = Gene.where(gene_set_id: 1).first(1) 
      @gene_example_1[:compare] = Gene.where(gene_set_id: 1).first(1) 
      @gene_example_1[:heatmap] = Gene.where(gene_set_id: 1).first(20)

      # @example[:search] = SampleGene.where(gene_set_id: 1, kind:'search')
      # @example[:compare] = SampleGene.where(gene_set_id: 1, kind:'compare')
      # @example[:heatmap] = SampleGene.where(gene_set_id: 1, kind:'heatmap')
    end  	 



    respond_to do |format|
      format.html
      format.json { render json: {"value" => @gene_example_1}}      
    end
  end

  def search_gene
  end

   def variety_params
      params.require(:variety).permit(:gene)
   end
end

