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

  options[:token] = nil
  opts.on( '-t', '--token <40 char auth token>', 'User\'s auth token.' ) do |user|
    options[:token] = user
  end

  options[:netrc] = File.exists? File.expand_path('~/.netrc')
  opts.on("-n", "--[no-]netrc", "Force use netrc.") do |netrc|
    options[:netrc] = netrc
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!

Octokit.auto_paginate = true

if options[:netrc]
  client = Octokit::Client.new(:netrc => true)
else
  if options[:token].nil?
    $stderr.print "Enter your github auth token: "
    token = gets.chomp
  else
    token = options[:token]
  end

  client = Octokit::Client.new(:access_token => token)
end

puts "#{client.login}'s GitHub repos:"

repos = []
if options[:sort] == "alpha"
  repos = client.repos(client.login, :sort => 'full_name')
elsif options[:sort] == "date"
  repos = client.repos(client.login, :sort => 'created')
end

if options[:display] == "table"
  ascii_table = table do |t|
    t.headings = ["Project Name", "Date", "Description"]
    repos.each do |repo|
      if !repo.fork?
        t << [ repo.name, repo.created_at.strftime('%F'), repo.description ]
      end
    end
  end

  puts ascii_table
elsif options[:display] == "list"
  repos.each do |repo|
    if !repo.fork?
      puts " * #{repo.name} - #{repo.created_at.strftime('%F')}"
      puts "   * #{repo.homepage}"    if !repo.homepage.nil? && !repo.homepage.empty?
      if !repo.private
        if not repo.url.nil?
          puts "   * #{repo.url}"
        else
          puts "   * http://github.com/#{client.login}/#{repo.name}"
        end
      end
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
