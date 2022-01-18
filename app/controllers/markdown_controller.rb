class MarkDownPath
	attr_accessor :path

	def to_partial_path
		'markdown/' + path
	end 
end

class MarkdownController < ApplicationController
	def show
		@path = MarkDownPath.new
		@path.path = params[:page]
		#puts @path
		render 'show'
	end
end
