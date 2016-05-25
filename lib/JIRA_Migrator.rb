
PROJECT_ROOT=ENV['PROJECT_ROOT']

def load_project(path)
  load "#{PROJECT_ROOT}/#{path}"
end

#Load Config

load_project 'lib/jira_migrator/config.rb'

$config = JIRAMigrator::Config.new


