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
    serve '/fonts', from: 'app/fonts'
    js :application, [ '/js/jquery.min.js', '/js/underscore-min.js', '/js/backbone-min.js', '/js/*.js' ]
    css :application, [ '/css/grids-responsive-min.css', '/css/font-awesome.min.css', '/css/*.css' ]
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

  # ===================================================== INDEX
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

  # ===================================================== MENUS(4)
  get '/booth' do
    erb :booth, :layout => !request.pjax?
  end

  get '/dashboard' do
  end

  get '/event' do
    erb :event, :layout => !request.pjax?
  end

  get '/aboutcodit' do
    erb :aboutcodit, :layout => !request.pjax?
  end




  # ===================================================== NFC EVENT
  # https://www.random.org/strings/?num=6&len=10&digits=on&upperalpha=on&loweralpha=on&unique=off&format=html&rnd=new
  # DKRC7AfHgf
  # WEXELr8qxG
  # DPWHXyl6hI
  # IYPhrpk5Xh
  # OT62d13tTR
  # oboZvyRpTM
  get '/event/DKRC7AfHgf' do
    erb :'event/left1'
  end

  get '/event/WEXELr8qxG' do
    erb :'event/left1-2'
  end

  get '/event/DPWHXyl6hI' do
    erb :'event/left2-3'
  end

  get '/event/IYPhrpk5Xh' do
    erb :'event/mid1-2'
  end

  get '/event/OT62d13tTR' do
    erb :'event/mid2-3'
  end

  get '/event/oboZvyRpTM' do
    erb :'event/right2-3'
  end

  # ===================================================== ERR HANDLING
  not_found do # 404 Not Found
    erb :'err/404'
  end

  error 500 do # 500 Internal Server Error
    erb :'err/500'
  end
end
