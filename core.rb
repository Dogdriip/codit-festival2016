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

  set :bind, '0.0.0.0'

  get '/' do
    erb :index, :layout => !request.pjax?
  end
  
  get '/map' do
    erb :map, :layout => !request.pjax?
  end
  
  get '/about' do
    erb :about, :layout => !request.pjax?
  end


  not_found do
    erb :notfound
  end

end
