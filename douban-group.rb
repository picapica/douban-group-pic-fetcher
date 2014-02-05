#!/usr/bin/env ruby
require File.expand_path('./common.rb', File.dirname(__FILE__))
$stdout.sync = true

require 'nokogiri'
require 'open-uri'

def http_open(url)
  begin
    return open(url)
  rescue OpenURI::HTTPError => e
    sleep 30 + rand(150)
    raise 'Fetcher: http error'
  end
end

start = 0
if ARGV.size > 0
  start = ARGV[0].to_i
end
group_url = "http://www.douban.com/group/Xsz/discussion?start=#{start}"
page = Nokogiri::HTML(http_open(group_url))

items = page.css("table.olt > tr")

$re_post_id = Regexp.new(%q{http://www.douban.com/group/topic/(.+)/})
$re_author_id = Regexp.new(%q{http://www.douban.com/group/people/(.+)/})

new_posts = []

items.each_with_index do |item, index|
  elements = item.css("td")
  next if elements.size < 4 or index < 1

  title = elements[0].css("a").first['title'].strip
  post_url = elements[0].css("a").first['href']
  post_id = post_url.scan($re_post_id)[0][0]

  author = elements[1].css("a").first.content
  author_url = elements[1].css("a").first['href']
  author_id = author_url.scan($re_author_id)[0][0]

  next if dm_post = Post.first({:post_id => post_id, :author_id => author_id, :title => title})

  begin
    post_page = Nokogiri::HTML(http_open(post_url))
  rescue
    next
  end

  post_doc = post_page.css(".topic-content .topic-doc h3 span")
  if post_time = post_doc.last.content
    post_time = Time.parse(post_time)
  end

  post_content = post_page.css(".topic-content .topic-doc .topic-content").first

  post_images = post_page.css(".topic-figure.cc img").map{|img| img['src']}
  post_text = post_content.content.strip

  post_hash = Digest::MD5.hexdigest(title + post_text)

  #next if dm_post = Post.first({:post_id => post_id, :author_id => author_id, :post_hash => post_hash})

  dm_post = Post.create(:post_id => post_id, :author_id => author_id, :post_hash => post_hash, :title => title, :post_time => post_time, :author => author, :content => post_text)
  post_images.each do |img_url|
    dm_post.pictures.create(:url => img_url)
  end

  puts dm_post
  puts dm_post.pictures

  new_posts << dm_post

  sleep 0.2
end

puts "Posts: %-6d  Pictures: %-6d \t New Posts: %-6d  New Pictures: %-6d\r\n" % [Post.count, Picture.count, new_posts.count, new_posts.map{|p| p.pictures.count}.reduce(0, :+)]
puts