module Guard
  class Xcodebuild < Plugin
    module Options
      DEFAULTS = {
        modified_paths:  [],
        test_paths:      ["."],
        all_on_start:    false,
        run_all:         { message: "Running all specs" },
        cmd:             nil,
        cmd_additional_args: nil,
        notification:    true,
        title:           "Xcodebuild results",
      }.freeze
      
      class << self
        def with_defaults(options = {})
          options[:file_args] ||= load_args_from_file
          options[:test_target] ||= find_test_target
          _deep_merge(DEFAULTS, options)          
        end

        private

        def _deep_merge(hash1, hash2)
          hash1.merge(hash2) do |_key, oldval, newval|
            if oldval.instance_of?(Hash) && newval.instance_of?(Hash)
              _deep_merge(oldval, newval)
            else
              newval
            end
          end
        end
        
        def load_args_from_file
          return unless File.file?(".xcodebuild-args")
          if json_file = File.open(".xcodebuild-args")
            load_args(json_file.read)
          end
        end

        def load_args(json_string)      
          begin
            args = JSON.parse(json_string)
          rescue          
          end   
          parse_args(args) unless args.nil?     
        end

        def parse_args(args)      
          s = ""
          args.keys.each { |k| s = s + "-#{k} #{args[k]} " }
          return s.strip
        end

        def find_test_target
          if targets = get_first_project_target_names
            targets.find {|f| f =~ /(Spec|Test)s?$/}
          end
        end
        
        def get_first_project_target_names
          if project_name = Dir["*.xcodeproj"].first
              Xcodeproj::Project.open(project_name).targets.collect(&:name)
          end      
        end
      end
    end
  end
end