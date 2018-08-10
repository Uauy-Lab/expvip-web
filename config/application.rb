require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require_relative '../lib/markdown_handler'
module WheatExpression
  class Application < Rails::Application

  end
end
