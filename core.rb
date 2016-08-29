require 'rubygems'
require 'sinatra/base'
require 'sinatra/assetpack'

class CoditFestival2016 < Sinatra::Base
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

  # temp
  set :bind, '0.0.0.0'

  get '/' do # 인덱스
    erb :index, :layout => !request.pjax?
  end
  
  get '/booth' do # 부스 배치도 / 목록
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
