require 'sinatra/base'
require 'yaml'
require_relative './url_shortener_admin'
require_relative './url_store.rb'
require_relative './analytics.rb'

class URLShortener < Sinatra::Base

  config = YAML.load_file(File.join(settings.root, 'config.yml'))

  enable :sessions
  set :session_secret, config['session_secret']

  not_found do
    slim :'errors/404', layout: :'layouts/index'
  end

  use URLShortenerAdmin

  get '/' do
    if config['default_target_url']
      redirect config['default_target_url'] 
    else
      halt 404
    end
  end

  get /(\w+)/ do
    key = params['captures'].first
    shortened_url_hash = URLStore.find(key)
    if shortened_url_hash and shortened_url_hash['target']
      Analytics.add_to_visit_count(key)
      redirect shortened_url_hash['target']
    else
      halt 404
    end
  end

end
