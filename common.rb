#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('./lib', File.dirname(__FILE__))

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'rubygems'
require 'bundler'
Bundler.require

# === DataMapper Setup === #
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:test.sqlite')
DataMapper::Model.raise_on_save_failure = true
DataMapper::Property::String.length(255)
#DataMapper::Logger.new($stdout, :debug)

class Post
  include DataMapper::Resource

  property :id, Serial

  property :post_id, String, :required => true
  property :title, String, :required => true
  property :post_time, Time

  property :author, String, :required => true
  property :author_id, String, :required => true

  property :content, Text
  property :post_hash, String

  property :created_at, DateTime

  has n, :pictures

  def to_s
    "[%s] %s %s %-40s\t- %s:%s" % [self.post_time, self.post_id, self.post_hash, self.title[0..20], self.author_id, self.author]
  end
end

class Picture
  include DataMapper::Resource

  property :id, Serial

  property :url, String

  property :created_at, DateTime

  belongs_to :post

  def to_s
    self.url
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
# === end DataMapper === #