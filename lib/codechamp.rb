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

def sort_again?
  puts
  puts "Would you like to sort the data differently? (Y/N)"
  maybe = gets.chomp.downcase

  until ["y", "n"].include?(maybe)
    puts "Please choose 'Y' or 'N'."
    maybe = gets.chomp.downcase
  end

  maybe == "y"
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

      def get_contributions_table(owner,repo)
        data = @github.get_contributions(owner,repo)
        @chaosarray = Array.new

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

        return @chaosarray
      end


  		def sort_contributions_table(sorted_chaosarray)
        table = sort?

        if table == "username"
          sorted_chaosarray = sort_by_username(sorted_chaosarray)
        elsif table == "adds"
          sorted_chaosarray = sort_by_adds(sorted_chaosarray)
        elsif table == "deletes"
          sorted_chaosarray = sort_by_deletes(sorted_chaosarray)
        elsif table == "changes"
          sorted_chaosarray = sort_by_changes(sorted_chaosarray)
        elsif table == "commits"
          sorted_chaosarray = sort_by_commits(sorted_chaosarray)
        end

        return sorted_chaosarray
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

app = Codechamp::App.new
app.connect_github

while again?
  target = app.ask_user_for_owner_and_repo
  nonsense = app.get_contributions_table(target[:owner], target[:repo])
  sorted_nonsense = app.sort_contributions_table(nonsense)
  ap sorted_nonsense

  until sort_again? == false
    sorted_nonsense = app.sort_contributions_table(nonsense)
    ap sorted_nonsense
  end
end



