# Rakefile
require 'sdoc' # and use your RDoc task the same way you used it before
require 'rdoc/task' # ensure this file is also required in order to use `RDoc::Task`

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'      # name of output directory
  rdoc.options << '--format=sdoc' # explictly set the sdoc generator
  rdoc.template = 'rails'         # template used on api.rubyonrails.org
end