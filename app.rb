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

  get '/post/:post_id/:post_hash/mail' do
    post = Post.first(:post_id => params[:post_id], :post_hash => params[:post_hash])

    mail = Mail.new do
      from    'simplax@gmail.com'
      to      'jiecaosuileyidi@googlegroups.com'
      message_id "%s.%s@1024.mib.cc" % [post.post_id, post.post_hash]
      subject "[douban:%s] %s - %s%s" % ['xsz', post.author, post.title, post.pictures.nil? ? '' : "[#{post.pictures.count}]" ]
      body    post.content
      post.pictures.each do |pic|
        file = pic.url.split('?', 2)[0].split('/')[-1]
        add_file :filename => file, :content => File.read("./newpic/#{file}")
        file = nil
      end
    end
    mail.header['References'] = "<%s@1024.mib.cc>" % params[:post_id]
    mail.header['In-Reply-To'] = "<%s@1024.mib.cc>" % params[:post_id]
    mail.deliver

    "<a href='#' onclick='window.close();return false;'>已发送，OK</a>"
  end
end