require 'sinatra/base'
require_relative './admin'

class LogIn < Sinatra::Base

  error 401 do
    slim :'errors/401', layout: :'layouts/index'
  end

  get '/admin/log-in' do
    slim :log_in, layout: :'layouts/index'
  end

  post '/admin/log-in' do
    user = Admin.authenticate(params[:email], params[:password])
    if user
      session[:user_email] = user["email"]
      redirect '/admin'
    else
      error 401
    end
  end
end
