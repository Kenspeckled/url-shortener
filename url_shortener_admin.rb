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
    @urls = URLStore.get_all
    if params['sort'] == 'name'
      @urls.sort_by!{|v| v['name'].to_s.downcase }
    elsif params['sort'] == 'date'
      @urls.sort_by!{|v| v['created_at'] ? Time.parse(v['created_at']).to_i : 0  }
    elsif params['sort'] == 'visits'
      @urls.sort_by!{|v| v['counter'].to_i }
    end
    if params['sort_order'] == 'desc'
      @urls.reverse!
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
    url = params['url']
    utm_campaign = params['utm_campaign']
    utm_source = params['utm_source']
    utm_medium = params['utm_medium']
    if utm_campaign and utm_source and utm_medium
      url = "#{url}?utm_source=#{utm_source}&utm_medium=#{utm_medium}&utm_campaign=#{utm_campaign}"
    end
    if name and name != '' and url and url != ''
      if key and key == ''
        key = rand(36**5).to_s(36)
      end
      URLStore.set({name: name, key: key, url: url})
      redirect '/admin'
    else
      halt 400
    end
  end
end