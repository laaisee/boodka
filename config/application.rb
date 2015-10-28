require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Boodka
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths << Rails.root.join('app', 'decorators')
    config.autoload_paths << Rails.root.join('app', 'calculators')

    config.generators do |g|
      g.test_framework :minitest, spec: true, fixture: false
      g.stylesheets = false
      g.javascripts = false
    end
  end
end
