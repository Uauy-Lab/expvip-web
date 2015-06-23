class WellcomeController < ApplicationController
  def default
  	 @studies = Study.all
  end

  def search_gene
  end

   def variety_params
      params.require(:variety).permit(:gene)
   end
end

