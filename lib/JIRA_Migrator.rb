
PROJECT_ROOT=ENV['PROJECT_ROOT']

def load_project(path)
  load "#{PROJECT_ROOT}/#{path}"
end

#Load Config

load_project 'lib/jira_migrator/config.rb'

$config = JIRAMigrator::Config.new

#Configure rest clients

load_project 'lib/jira_migrator/rest_client.rb'

$source_client =
  JIRA_Client.new(
    $config["source"]["server"],
    "#{$config["source"]["username"]}:#{$config["source"]["password"]}")

$destination_client =
  JIRA_Client.new(
    $config["destination"]["server"],
    "#{$config["destination"]["username"]}:#{$config["destination"]["password"]}")

$user_mapping = JIRAMigrator::UserMap.new



