module JIRAMigrator
  class UserMap

    require 'json'
    require 'similar_text'

    SOURCE_PATH = "/rest/api/latest/user/assignable/multiProjectSearch?projectKeys=#{$config["source"]["project"]}"
    DESTINATION_PATH = "/rest/api/latest/user/assignable/multiProjectSearch?projectKeys=#{$config["destination"]["project"]}"

    OVER_WRITES = $config["user_map"]

    def initialize

      source_response = $source_client.get(SOURCE_PATH)
      destination_response = $destination_client.get(DESTINATION_PATH)

      source_users = JSON.parse(source_response)
      destination_users = JSON.parse(destination_response)

      user_map = {}

      source_users.each do |s_user|

        d_user = destination_users.select do |_user|
          _user["displayName"].downcase.similar(s_user["displayName"].downcase) > 90
        end.first

        if d_user != nil
          user_map[s_user["key"]] = d_user["key"]
        else
          if OVER_WRITES[s_user["key"]] != nil
            user_map[s_user["key"]] = OVER_WRITES[s_user["key"]]
          else
            user_map[s_user["key"]] = s_user["key"]
          end
        end
      end
      @user_map = user_map
    end

    def [](source_user)
      @user_map[source_user]
    end

    def users
      @user_map
    end

  end
end
