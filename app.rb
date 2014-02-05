#!/usr/bin/env ruby
# encoding: utf-8

class AppController < Sinatra::Base
  enable :sessions

  configure {
    set :server, :puma
  }
  
  get '/' do
    @posts = Post.all(:order => [:post_time.asc])
    
    haml :post_list
  end
  
  get '/post/:post_id/:post_hash' do
    @post = Post.first(:post_id => params[:post_id], :post_hash => params[:post_hash])
    
    haml :post_show
  end
end