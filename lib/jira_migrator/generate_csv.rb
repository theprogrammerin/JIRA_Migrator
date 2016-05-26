module JIRAMigrator
  class GenerateCSV

    require 'csv'

    CSV_FIELDS = [
      "key",
      "summary",
      "description",
      "issuetype",
      "parent_key",
      "priority",
      "assignee",
      "reporter",
      "creator",
      "epic_link",
      "epic_name",
      "epic_color",
      "epic_status",
      "comments",
      "created",
      "status",
      "rank"
    ]

    PROJECT = $config["source"]["project"]

    FIELDS_REVERSE_MAP = {
      summary: "summary",
      description: "description",
      epic_link: "customfield_10008",
      epic_name: "customfield_10009",
      epic_status: "customfield_10010",
      epic_color: "customfield_10011",
      rank: "customfield_10012",

    }

    STATUS_CODE_MAP = {
      "10000" => "10000",
      "3"     => "3",
      "10400" => "10601",
      "10100" => "10001"
    }

    ISSUE_BASE_MAP = "/rest/api/latest/issue/"

    START_ISSUES = 0
    MAX_ISSUES = 400

    ISSUES = (START_ISSUES..MAX_ISSUES).to_a
    # ISSUES = [91]

    def initialize

    end

    def jira_date(_timestamp)
      DateTime.parse(_timestamp).strftime("%m/%d/%y %I:%M:%S %p")
    end

    def comment_to_text(comments_data)
      comments = comments_data["comments"].map do |comment_data|
        created_at = jira_date(comment_data["created"])
        user = $user_mapping[comment_data["author"]["name"]]
        body = comment_data["body"]

        $user_mapping.users.each do |old_name, new_name|
          body.gsub!(old_name, new_name)
        end

        "#{created_at}; #{user}; #{body}"
      end.join(",")
    end

    def fix_status(orig_status)
      return orig_status if orig_status == nil
      STATUS_CODE_MAP.each do |s, c|
        orig_status.gsub!(s, c)
      end
      orig_status
    end

    def generate

      CSV.open("./dump_#{PROJECT}_#{ISSUES.count}.csv", "w") do |csv|

        csv << CSV_FIELDS

        ISSUES.each do |issue_id|

          puts "Fetching Issue#{issue_id}"

          key = "#{PROJECT}-#{issue_id}"
          begin
            issue_response = $source_client.get("#{ISSUE_BASE_MAP}#{key}")
            issue_data = JSON.parse(issue_response)

            reporter_name = $user_mapping[issue_data["fields"]["reporter"]["name"]] || issue_data["fields"]["reporter"]["name"]

            creator_name = $user_mapping[issue_data["fields"]["creator"]["name"]] || issue_data["fields"]["creator"]["name"]

            assignee_name = issue_data["fields"]["assignee"] == nil ? nil : $user_mapping[issue_data["fields"]["assignee"]["name"]]

            csv_data = {
              key: issue_data["key"],
              issuetype: issue_data["fields"]["issuetype"]["name"],
              assignee: assignee_name,
              reporter: reporter_name,
              creator: creator_name,
              created: jira_date(issue_data["fields"]["created"]),
              status: fix_status(issue_data["fields"]["status"]["id"]),
              priority: issue_data["fields"]["priority"]["id"]
            }

            FIELDS_REVERSE_MAP.each do |k, v|
              csv_data[k] = issue_data["fields"][v]
            end

            if issue_data["fields"]["parent"] != nil
              csv_data[:parent_key] = issue_data["fields"]["parent"]["key"]
            else
              csv_data[:parent_key] = nil
            end

            # binding.pry
            if issue_data["fields"]["comment"] != nil
              csv_data[:comments] = comment_to_text(issue_data["fields"]["comment"])
            else
              csv_data[:comments] = nil
            end

            if csv_data[:epic_status] != nil
              csv_data[:epic_status] = fix_status(csv_data[:epic_status]["id"])
            end

            row = []
            CSV_FIELDS.each do |field|
              row << csv_data[field.to_sym]
            end
            csv << row

          rescue RestClient::ResourceNotFound=>e
            next
          end
        end

      end

    end

