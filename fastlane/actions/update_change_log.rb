module Fastlane
    module Actions
      class UpdateChangeLogAction < Action
        def self.run(params)
            log = params[:log]
            raise "Invalid log object".red unless !log[:title].empty? and !log[:version].empty?
  
            readme = File.read(params[:changelogfile])
            log_text = "## [#{log[:title]}](https://github.com/yellowmessenger/YMChatbot-iOS/releases/tag/#{log[:version]}) (#{Time.now.strftime("%Y-%m-%d")})\n\n"
  
            des = ""
            feature = log[:add].map { |i| "* #{i}" }.join("\n") unless log[:add].nil?
            des = des + "#### New Feature 🚀\n#{feature}\n\n" unless feature.nil? or feature.empty?
  
            fix = log[:fix].map { |i| "* #{i}" }.join("\n") unless log[:fix].nil?
            des = des + "#### Bug Fix 🐛\n#{fix}\n\n" unless fix.nil? or fix.empty?

            enhancement = log[:enhancement].map { |i| "* #{i}" }.join("\n") unless log[:enhancement].nil?
            des = des + "#### Enhancement 🚧\n#{enhancement}\n\n" unless enhancement.nil? or enhancement.empty?
            
            remove = log[:remove].map { |i| "* #{i}" }.join("\n") unless log[:remove].nil?
            des = des + "#### Remove 🗑️\n#{remove}\n\n" unless remove.nil? or remove.empty?

            log_text = log_text + des
  
            File.open(params[:changelogfile], 'w') { |file| file.write(readme.sub("-----", "-----\n\n#{log_text}---")) }
  
            return {:title => log[:title], :text => "## What's Changed\n\n" + des}
        end
  
        #####################################################
        # @!group Documentation
        #####################################################
  
        def self.description
          "Update the change log file with the content of log"
        end
  
        def self.details
          "Generally speaking, the log is return value of extract_current_change_log action"
        end
  
        def self.available_options
          [
            FastlaneCore::ConfigItem.new(key: :log,
                                         env_name: "KF_UPDATE_CHANGE_LOG_LOG",
                                         description: "Change log extracted by pre change log file",
                                         is_string: false
                                         ),
            FastlaneCore::ConfigItem.new(key: :changelogfile,
                                         env_name: "KF_UPDATE_CHANGE_LOG_CHANGE_LOG_FILE",
                                         description: "The change log file, if not set, CHANGELOG.md will be used",
                                         default_value: "CHANGELOG.md")
          ]
        end
  
        def self.authors
          ["sankalp211"]
        end
  
        def self.is_supported?(platform)
          true
        end
      end
    end
  end