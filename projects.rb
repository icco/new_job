#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

require 'date'
require 'optparse'
require 'time'

# Argument parsing
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: projects.rb [options]"

  options[:display] = "table"
  opts.on( '-d', '--display {table,list}', "Define display type. Default: #{options[:display]}" ) do |type|
    options[:display] = type
  end

  options[:sort] = "alpha"
  opts.on( '-s', '--sort {alpha,date}', "Define sort type. Default: #{options[:sort]}" ) do |type|
    options[:sort] = type
  end

  options[:user] = nil
  opts.on( '-u', '--user username', 'Which user to pull repos from.' ) do |user|
    options[:user] = user
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!

if options[:user].nil?
  $stderr.print "Enter your github username: "
  user = gets.chomp
else
  user = options[:user]
end

$stderr.print "Enter your github password: "
token = STDIN.noecho(&:gets)

puts ""

client = Octokit::Client.new(:login => user, :password => token.strip, :auto_traversal => true)

puts ""
puts "#{user}'s GitHub repos:"

repos = []
if options[:sort] == "alpha"
  repos = client.repos(user, :sort => 'full_name')
elsif options[:sort] == "date"
  repos = client.repos(user, :sort => 'created')
end

if options[:display] == "table"
  ascii_table = table do |t|
    t.headings = ["Project Name", "Date", "Description"]
    repos.each do |repo|
      if !repo.fork?
        t << [ repo.name, Date.parse(repo.created_at).to_s, repo.description ]
      end
    end
  end

  puts ascii_table
elsif options[:display] == "list"
  repos.each do |repo|
    if !repo.fork?
      puts " * #{repo.name} - #{Date.parse(repo.created_at).to_s}"
      puts "   * #{repo.homepage}"    if !repo.homepage.nil? && !repo.homepage.empty?
      puts "   * #{repo.html_url}"    if !repo.private
      puts "   * #{repo.description}" if !repo.description.nil? && !repo.description.empty?
      puts ""
    end
  end
elsif options[:display] == "dump"
  repos.each do |repo|
    p repo if !repo.fork?
    puts ""
  end
end
