#!/usr/bin/env ruby
# encoding: utf-8

class AppController < Sinatra::Base
  enable :sessions

  configure {
    set :server, :puma
  }
  
  get '/' do
    'Hello world!'
  end
end