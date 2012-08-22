#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

require 'time'
require 'date'
require 'io/console'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: projects.rb [options]"

  options[:display] = "table"
  opts.on( '-d', '--display {table,list}', 'Define display type.' ) do |type|
    options[:display] = type
  end

  options[:user] = nil
  opts.on( '-u', '--user username', 'Which user to pull repos from.' ) do |user|
    options[:user] = user
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

if options[:user].nil?
  print "Enter your github username: "
  user = gets.chomp
else
  user = options[:user]
end

print "Enter your github password: "
token = STDIN.noecho(&:gets)

client = Octokit::Client.new(:login => user, :password => token.strip, :auto_traversal => true)

puts ""
puts "#{user}'s GitHub repos:"

if options[:display] == "table"
  ascii_table = table do |t|
    t.headings = ["Project Name", "Date", "Description"]
    client.repos(user).each do |repo|
      if !repo.fork?
        t << [ repo.name, Date.parse(repo.created_at).to_s, repo.description ]
      end
    end
  end

  puts ascii_table
elsif options[:display] == "list"
  client.repos(user).each do |repo|
    if !repo.fork?
      puts " * #{repo.name} - #{Date.parse(repo.created_at).to_s}"
      puts "   * #{repo.homepage}" if !repo.homepage.nil? && !repo.homepage.empty?
      puts "   * #{repo.html_url}" if !repo.private
      puts "   * #{repo.description}" if !repo.description.nil? && !repo.description.empty?
      puts ""
    end
  end
elsif options[:display] == "dump"
  client.repos(user).each do |repo|
    p repo if !repo.fork?
    puts ""
  end
end
