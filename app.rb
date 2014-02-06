#!/usr/bin/env ruby
# encoding: utf-8

class AppController < Sinatra::Base
  enable :sessions

  configure {
    set :server, :puma
  }

  get '/' do
    @total_posts_count = Post.count
    @per_page    = (params[:per_page] || 50).to_i
    @total_pages_count = (@total_posts_count - 1) / @per_page + 1

    page = (params[:page] || 1).to_i
    @page = (page - 1) % @total_pages_count + 1
    start = (@page - 1) * @per_page

    posts = Post.all(:order => [:post_id.desc, :created_at.desc])
    @posts = posts[start, @per_page]

    haml :post_list
  end

  get '/post/:post_id' do
    @posts = Post.all(:post_id => params[:post_id], :order => [:created_at.desc])

    haml :post_show
  end

  get '/post/:post_id/:post_hash/mail' do
    post = Post.first(:post_id => params[:post_id], :post_hash => params[:post_hash])
    post_content = "#{post.content} \r\n #{post.post_url}"

    mail = Mail.new do
      from    'jiecao1024@gmail.com'
      to      'jiecaosuileyidi@googlegroups.com'
      message_id "%s.%s@1024.mib.cc" % [post.post_id, post.post_hash]
      subject "[douban:%s] %s - %s%s" % ['xsz', post.author, post.title, post.pictures.nil? ? '' : "[#{post.pictures.count}]" ]
      body    post_content
      post.pictures.each do |pic|
        file = pic.url.split('?', 2)[0].split('/')[-1]
        add_file :filename => file, :content => File.read("./newpic/#{file}")
        file = nil
      end
    end
    mail.header['References'] = "<%s@1024.mib.cc>" % params[:post_id]
    mail.header['In-Reply-To'] = "<%s@1024.mib.cc>" % params[:post_id]
    mail.deliver

    "<a href='#' onclick='window.close();return false;'>#{post.author} #{post.title} 已发送，OK</a>"
  end
end