class WellcomeController < ApplicationController
  def default
  	
  end

  def search_gene
  end

   def variety_params
      params.require(:variety).permit(:gene)
   end
end


