require 'sequenceserver'
require "#{Rails.root}/lib/links.rb"  
Rails.application.routes.draw do
  
  root 'wellcome#default'
  get 'wellcome/search_gene'

  get 'download' => 'download#default'
  get 'cite' =>  'wellcome#cite'
 
  resources :genes  do
    collection do
      get 'autocomplete'
      get 'heatmap'
      post 'forward'
      get 'forward'
      post 'share' 
      get 'set_studies_session'     
      get 'show'
      get 'examples'
    end
  end
  
  get 'expression_values/gene' => 'expression_values#gene'
  get 'expression_values/transcript' => 'expression_values#transcript'
  get 'expression_values/genes' => 'expression_values#genes'

  

  resources :gene_sets  do
    collection do
      get 'set_gene_set_session'     
    end
  end
  
  begin
    config_ss = {}
    if Rails.application.config.respond_to?(:sequenceserver_config)
      config_file = Rails.application.config.sequenceserver_config 
      config_ss[:config_file]  =  config_file if Dir.exist? config_file
    end
    SequenceServer.init config_ss
    mount SequenceServer, :at => "sequenceserver"
  rescue Exception => e
    Logger.new(STDOUT).info "Unable to start sequenceserver: " + e.to_s
  end
  
  
end
