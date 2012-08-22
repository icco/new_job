#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

require 'time'
require 'date'
require 'io/console'

print "Enter your github username: "
user = gets.chomp

print "Enter your github password: "
token = STDIN.noecho(&:gets)

client = Octokit::Client.new(:login => user, :password => token, :auto_traversal => true)

puts ""
puts "#{user}'s GitHub repos:"

ascii_table = table do |t|
  t.headings = ["Project Name", "Date", "Description"]
  client.repos(user).each do |repo|
    if !repo.fork?
      t << [ repo.name,Date.parse(repo.created_at).to_s, repo.description]
    end
  end
end

puts ascii_table
