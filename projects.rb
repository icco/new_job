#!/usr/bin/env ruby

require 'time'
require 'date'
require 'octokit' # gem install octokit
require 'terminal-table/import' # gem install terminal-table


print "Enter your github username: "
user = gets.chomp

print "Enter your github password: "
token = gets.chomp

client = Octokit::Client.new(:login => user, :password => token)

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
