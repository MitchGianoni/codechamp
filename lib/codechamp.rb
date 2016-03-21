require "pry"
require "httparty"
require "json"
require "ap"

require "codechamp/version"
require "codechamp/github"

def again?
  puts
  puts "Would you like to search a repo? (Y/N)"
  choice = gets.chomp.downcase

  until ["y","n"].include?(choice)
    puts "Please choose 'Y' or 'N'."
    choice = gets.chomp.downcase
  end

  choice == "y"
end

def sort?
  puts
  puts "What would you like to use to sort the data? \n"
  puts "(username/adds/deletes/changes/commits): \n"
  use = gets.chomp.downcase

  until ["username","adds","deletes","changes","commits"].include?(use)
    puts "Please choose 'username' 'adds' 'deletes' 'changes' 'commits': \n"
    use = gets.chomp.downcase
  end

  return use
end

module Codechamp
	class App
  		def connect_github
  			puts "Please Enter Auth Token:"
  			auth_token = gets.chomp
  			@github = Github.new(auth_token)
        @chaosarray = Array.new
  		end

  		def ask_user_for_owner_and_repo
        puts "Which Owner?"
        owner = gets.chomp
        puts "Which Repo?"
        repo = gets.chomp

        return choice = { owner: owner, repo: repo }
  		end

      def collect_data(username, adds, deletes, changes, commits)
        chaos = { username: username, adds: adds, deletes: deletes, changes: changes, commits: commits }
        @chaosarray.push(chaos)
      end

  		def print_contributions_table(owner, repo)
        data = @github.get_contributions(owner,repo)

        table = sort?

        data.each do |item|
          adds = 0
          deletes = 0
          commits = 0 
          username = item["author"]["login"]
          weeks = item["weeks"]
          weeks.each do |week|
            adds += week["a"]
            deletes += week["d"]
            commits += week["c"]
          end
          changes = adds + deletes 


          collect_data(username, adds, deletes, changes, commits)
        end

        if table == "username"
          @chaosarray = sort_by_username(@chaosarray)
        elsif table == "adds"
          @chaosarray = sort_by_adds(@chaosarray)
        elsif table == "deletes"
          @chaosarray = sort_by_deletes(@chaosarray)
        elsif table == "changes"
          @chaosarray = sort_by_changes(@chaosarray)
        elsif table == "commits"
          @chaosarray = sort_by_commits(@chaosarray)
        end

        return @chaosarray
      end 	

      def sort_by_username(chaosarray)
        chaosarray.sort_by { |hash| hash[:username] }
      end

      def sort_by_adds(chaosarray)
        chaosarray.sort_by { |hash| hash[:adds] }
      end

      def sort_by_deletes(chaosarray)
        chaosarray.sort_by { |hash| hash[:deletes] }
      end

      def sort_by_changes(chaosarray)
        chaosarray.sort_by { |hash| hash[:changes] }
      end

      def sort_by_commits(chaosarray)
        chaosarray.sort_by { |hash| hash[:commits] }
      end

	end
end

while again?
  app = Codechamp::App.new
  app.connect_github
  target = app.ask_user_for_owner_and_repo
  nonsense = app.print_contributions_table(target[:owner], target[:repo])
  ap nonsense
end



