#!/usr/bin/env ruby
# encoding: utf-8

class AppController < Sinatra::Base
  enable :sessions

  configure {
    set :server, :puma
  }
  
  get '/' do
    @posts = Post.all(:order => [:post_time.desc])
    
    haml :post_list
  end
  
  get '/post/:post_id' do
    @posts = Post.all(:post_id => params[:post_id], :order => [:post_time.desc])
    
    haml :post_show
  end
end