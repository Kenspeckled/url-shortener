require 'sinatra/base'
require 'yaml'
require './login.rb'
require './url_store.rb'

class URLShortenerAdmin < Sinatra::Base
  config = YAML.load_file('config.yml')

  use LogIn

  error 400 do
    slim :'errors/400', layout: :'layouts/index'
  end

  before do
    if !session[:user_email]
      error 401
    end
  end

  get '/admin' do
    @base_url = config['base_url'] || request.url.sub(request.path, "").sub("?#{request.query_string}", "")
    @readable_base_url = @base_url.to_s.sub("http://","").sub("https://","")
    @shortened_url_collection = URLStore.get_all
    if params['sort'] == 'name'
      @shortened_url_collection.sort_by!{|v| v['name'].to_s.downcase }
    elsif params['sort'] == 'date'
      @shortened_url_collection.sort_by!{|v| v['created_at'] ? Time.parse(v['created_at']).to_i : 0  }
    elsif params['sort'] == 'visits'
      @shortened_url_collection.sort_by!{|v| v['counter'].to_i }
    end
    if params['sort_order'] == 'desc'
      @shortened_url_collection.reverse!
      @next_sort_order = 'asc'
    else
      @next_sort_order = 'desc'
    end
    slim :show, layout: :'layouts/index'
  end


  get '/admin/create' do
    slim :create, layout: :'layouts/index'
  end

  post '/admin/url/new' do
    name = params['name']
    key = params['key']
    target = params['target']
    utm_campaign = params['utm_campaign']
    utm_source = params['utm_source']
    utm_medium = params['utm_medium']
    if utm_campaign != '' and utm_source != '' and utm_medium != ''
      target = "#{target}?utm_source=#{utm_source}&utm_medium=#{utm_medium}&utm_campaign=#{utm_campaign}"
    end
    if name and name != '' and target and target != ''
      if key and key == ''
        #there are 46656 possible combinations
        key = rand(36**3).to_s(36)
        while URLStore.find(key)
          key = rand(36**3).to_s(36)
        end
      else
        halt 400 if URLStore.find(key)
      end
      URLStore.set({name: name, key: key, target: target})
      redirect '/admin'
    else
      halt 400
    end
  end

end
