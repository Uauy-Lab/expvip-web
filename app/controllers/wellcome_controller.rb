class WellcomeController < ApplicationController

  def get_random_genes(gene_set_id, count: 50)
    random_genes = Gene.where(gene_set_id: gene_set_id).order("RAND()").limit(count)
    example = {}
    example[:search]  = random_genes.first
    example[:compare] = random_genes.last
    example[:heatmap] = random_genes.map { |e| e.id }
    example
  end

  def get_example_genes(gene_set_id)
    example = {}
    example[:search]  = SampleGene.where(gene_set_id: gene_set_id, kind:'search')
    example[:compare] = SampleGene.where(gene_set_id: gene_set_id, kind:'compare')
    example[:heatmap] = SampleGene.where(gene_set_id: gene_set_id, kind:'heatmap')
    if example[:search].size == 0
      return get_random_genes(gene_set_id)  
    end
    example[:search]  = Gene.where(id: example[:search] .first.gene_id).first
    example[:compare] = Gene.where(id: example[:compare].first.gene_id).first
    example
  end

  def default
    @studies = Study.all
    @gene_example_1 = {}
    @example = {}
    if params[:gene_set_selector]
      @example = get_example_genes(params[:gene_set_selector])
    elsif session[:gene_set_id]
      @example = get_example_genes(session[:gene_set_id])
    else
      default_gene_set = GeneSet.find_by(:selected => true)
      default_gene_set = default_gene_set ? default_gene_set.id : 1
      @example = get_example_genes(default_gene_set)
    end

    heatmap_examples = []
    counter = 0
    @example[:heatmap].each do |el|
      x = Gene.where(id: el)
      heatmap_examples[counter] = x[0].gene
      counter = counter + 1
    end
    @example[:heatmap] = heatmap_examples

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
