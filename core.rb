require 'rubygems'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra-websocket'

class CoditFestival2016 < Sinatra::Base
  set :server, 'thin'
  set :sockets, []
  set :bind, '0.0.0.0'

  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack
  assets do
    serve '/js', from: 'app/js'
    serve '/css', from: 'app/css'
    serve '/images', from: 'app/images'
    js :application, [ '/js/jquery.min.js', '/js/underscore-min.js', '/js/backbone-min.js', '/js/*.js' ]
    css :application, [ '/css/*.css' ]
    js_compression :jsmin
    css_compression :simple
  end

  class Sinatra::Request
    def pjax?
      env['HTTP_X_PJAX'] || self['_pjax']
    end
  end

  # authentication
  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'jungchulisajae']
    end
  end

  get '/admin' do
    protected!
    if !request.websocket?
      erb :admin, :layout => !request.pjax?
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send("Hello World!")
          settings.sockets << ws
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        end
        ws.onclose do
          warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end
    end
  end


  get '/' do
    if !request.websocket?
      erb :index, :layout => !request.pjax?
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send("Hello World!")
          settings.sockets << ws
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        end
        ws.onclose do
          warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end
    end
  end
  
  get '/booth' do
    erb :booth, :layout => !request.pjax?
  end

  get '/event' do
  end
  
  get '/about' do
    erb :about, :layout => !request.pjax?
  end

  

  get '/qr/test' do
    erb :'qr/test', :layout => !request.pjax?
  end





  not_found do # 404 Not Found
    erb :'err/404', :layout => !request.pjax?
  end

  error 500 do # 500 Internal Server Error
    erb :'err/500', :layout => !request.pjax?
  end
end
