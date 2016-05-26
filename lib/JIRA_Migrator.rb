
PROJECT_ROOT=ENV['PROJECT_ROOT']

def load_project(path)
  load "#{PROJECT_ROOT}/#{path}"
end

#Load Config

load_project 'lib/jira_migrator/config.rb'

$config = JIRAMigrator::Config.new


SOURCE_CLIENT = JIRA_Client.new("https://tinyowl.atlassian.net", "ashutosh:Ashu@2609")
DESTINATION_CLIENT = JIRA_Client.new("https://roadrunnr.atlassian.net", "ashutosh.agrawal:Ashu@2609")

