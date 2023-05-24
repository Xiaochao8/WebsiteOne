# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'active_storage/engine'
require 'action_text/engine'
require 'singleton-client'

%w(
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  rails/test_unit/railtie
  sprockets/railtie
).each do |railtie|
  require railtie
rescue LoadError
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Bundler.require(:default, Rails.env)

module WebsiteOne
  class Application < Rails::Application
    config.active_support.cache_format_version 7.0
    # config.autoloader = :zeitwerk
    # necessary to make Settings available
    Config::Integrations::Rails::Railtie.preload
    # config.load_defaults 5.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.exceptions_app = routes

    config.active_record.legacy_connection_handling = false

    config.action_mailer.delivery_method = Settings.mailer.delivery_method.to_sym
    config.action_mailer.smtp_settings = Settings.mailer.smtp_settings.to_hash
    config.action_mailer.default_url_options = { host: 'www.agileventures.org' }

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    ENV['TZ'] = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = false

    config.assets.enabled = true

    # ensure svg assets are compiled in production
    config.assets.precompile += %w(jobs.svg lady-dev.svg real-projects.svg runners.svg standups.svg)

    config.autoload_paths += Dir[Rails.root.join('app', '**/')]
    config.autoload_paths += Dir[Rails.root.join('lib')]

    Sgtn.product_name = 'WebsiteOne'
    Sgtn.version = '1.0.0'
    Sgtn.vip_server = 'http://localhost:8091'
    Sgtn.source_bundle = './config/sources'
  end
end
