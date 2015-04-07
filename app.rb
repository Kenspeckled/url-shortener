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
    shortened_url = params['captures'].first
    full_url = URLStore.find(shortened_url)
    if full_url
      Analytics.add_to_counter(shortened_url)
      status 301
      redirect full_url
    else
      halt 404
    end
  end

end
