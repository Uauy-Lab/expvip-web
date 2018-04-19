class WellcomeController < ApplicationController
  def default
  	 @studies = Study.all  	 
  	 puts "This is the gene set id: #{session[:gene_set_id]}"
  	 if params[:gene_set_selector]
  	 	@gene_example_1 = Gene.where(gene_set_id: params[:gene_set_selector]).first(2) 
  	 elsif session[:gene_set_id]
  	 	@gene_example_1 = Gene.where(gene_set_id: session[:gene_set_id]).first(2) 
  	 else
  	 	@gene_example_1 = Gene.where(gene_set_id: 1).first(2) 
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

