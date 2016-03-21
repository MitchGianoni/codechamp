
module Codechamp
	class Github
		include HTTParty
		  base_uri "https://api.github.com"

      def initialize(token)
        @headers = {
          "Authorization" => "token #{token}",
          "User-Agent"	=> "HTTParty"
        }
        @response = nil		
      end

      def get_user(username)
        Github.get("/users/#{username}", headers: @headers)
      end

      def get_contributions(owner, repo)
        Github.get("/repos/#{owner}/#{repo}/stats/contributors", headers: @headers)
      end
  end
end

## response = get_contributions(whatever)
## contributor = response.first

## get_user_totals(contributor) => ["kingcons", 2000, 1822, 207], {user: "kingcons", a: 2000}
## enumerable module