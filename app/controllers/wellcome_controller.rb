class WellcomeController < ApplicationController
  def default
    @studies = Study.all
    @gene_example_1 = {}
    @example = {}


    if params[:gene_set_selector]

      @example[:search] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'search')
      @example[:compare] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'compare')
      @example[:heatmap] = SampleGene.where(gene_set_id: params[:gene_set_selector], kind:'heatmap')

      @example[:search] = Gene.where(id: @example[:search].first.gene_id)
      @example[:compare] = Gene.where(id: @example[:compare].first.gene_id)

      heatmap_examples = []
      counter = 0
      @example[:heatmap].each do |el|
        x = Gene.where(id: el.gene_id)
        heatmap_examples[counter] = x[0].name
        counter = counter + 1
      end
      @example[:heatmap] = heatmap_examples

    elsif session[:gene_set_id]

      @example[:search] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'search')
      @example[:compare] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'compare')
      @example[:heatmap] = SampleGene.where(gene_set_id: session[:gene_set_id], kind:'heatmap')

      @example[:search] = Gene.where(id: @example[:search].first.gene_id)
      @example[:compare] = Gene.where(id: @example[:compare].first.gene_id)

      heatmap_examples = []
      counter = 0
      @example[:heatmap].each do |el|
        x = Gene.where(id: el.gene_id)
        heatmap_examples[counter] = x[0].name
        counter = counter + 1
      end
      @example[:heatmap] = heatmap_examples

    else

      default_gene_set = GeneSet.find_by(:selected => true)

      if default_gene_set
        @example[:search] = SampleGene.where(gene_set_id: default_gene_set.id, kind:'search')
        @example[:compare] = SampleGene.where(gene_set_id: default_gene_set.id, kind:'compare')
        @example[:heatmap] = SampleGene.where(gene_set_id: default_gene_set.id, kind:'heatmap')
        session[:gene_set_id] = default_gene_set.id
      else
        @example[:search] = SampleGene.where(gene_set_id: 1, kind:'search')
        @example[:compare] = SampleGene.where(gene_set_id: 1, kind:'compare')
        @example[:heatmap] = SampleGene.where(gene_set_id: 1, kind:'heatmap')
        session[:gene_set_id] = 1
      end

      @example[:search] = Gene.where(id: @example[:search].first.gene_id)
      @example[:compare] = Gene.where(id: @example[:compare].first.gene_id)


      heatmap_examples = []
      counter = 0
      @example[:heatmap].each do |el|
        x = Gene.where(id: el.gene_id)
        heatmap_examples[counter] = x[0].name
        counter = counter + 1
      end
      @example[:heatmap] = heatmap_examples

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
