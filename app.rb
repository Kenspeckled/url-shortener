require 'sinatra/base'
require 'yaml'
require './url_shortener_admin'
require './url_store.rb'
require './analytics.rb'

class URLShortener < Sinatra::Base

  config = YAML.load_file('config.yml')

  enable :sessions
  set :session_secret, config['session_secret']

  not_found do
    "not found"
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
    target = URLStore.find(key)['target']
    if target
      Analytics.add_to_visit_count(key)
      redirect target
    else
      halt 404
    end
  end

end
