class WellcomeController < ApplicationController
  def default
    @studies = Study.all  	         
    @gene_example_1 = {}
    @example = {}


    if params[:gene_set_selector]      
      
      @gene_example_1[:heatmap] = Gene.where(gene_set_id: params[:gene_set_selector]).first(20)

      @example[:search] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'search')
      @example[:compare] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'compare')
      # @example[:heatmap] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'heatmap')

      puts "\n\n\n\n\n\n\nThis is the example search: #{@example[:search].first.gene_name}\nThis is the example compare: #{@example[:compare].first.gene_name}\n\n\n\n\n\n\n"
    elsif session[:gene_set_id]
      
      @gene_example_1[:heatmap] = Gene.where(gene_set_id: session[:gene_set_id]).first(20)

      @example[:search] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'search')
      @example[:compare] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'compare')
      # @example[:heatmap] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'heatmap')

      puts "\n\n\n\n\n\n\nThis is the example search: #{@example[:search].first.gene_name}\nThis is the example compare: #{@example[:compare].first.gene_name}\n\n\n\n\n\n\n"
    else
      
      @gene_example_1[:heatmap] = Gene.where(gene_set_id: 1).first(20)

      @example[:search] = SampleGene.where(gene_set_id: 1, kind:'search')
      @example[:compare] = SampleGene.where(gene_set_id: 1, kind:'compare')
      # @example[:heatmap] = SampleGene.where(gene_set_id: 1, kind:'heatmap')
      puts "\n\n\n\n\n\n\nThis is the example search: #{@example[:search].first.gene_name}\nThis is the example compare: #{@example[:compare].first.gene_name}\n\n\n\n\n\n\n"
    end  	 



    respond_to do |format|
      format.html
      format.json { render json: {"value" => @example}}      
    end
  end

  def search_gene
  end

   def variety_params
      params.require(:variety).permit(:gene)
   end
end

