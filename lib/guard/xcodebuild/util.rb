require 'xcodeproj'
require 'json'

module Guard
  class Xcodebuild < Plugin
    module Util
      TEST_FILE_REGEXP = /(Test|Spec)\.(m|swift)$/
      # Find test class from input paths.
      # 
      # - if the path is end with Test.m/Test.mm/Spec.m/Spec.mm, then it is a test class, return the class name of it
      #
      # @param [Array<String>] paths
      # @param [Array<String>] test_path
      #
      class << self              

        def xcodebuild_command(options = {})
          args = only_testing_arg(options[:modified_paths], 
            options[:test_paths], options[:test_target])
          # Pipefail is required so the xcpretty pipe doesnt swallow xcodebuild errors
          commands = ["set -o pipefail; xcodebuild test"]  
          commands << options[:file_args] if options[:file_args] && options[:file_args].strip != ""
          commands << options[:args] if options[:args] && options[:args].strip != ""
          commands << args if args && args.strip != ""
          commands << "| xcpretty"
          commands.join(" ")          
        end

        private          

        def only_testing_arg(modified_paths, test_paths, test_target)
          test_files = test_classes_with_paths(modified_paths, test_paths)
          if test_files.size > 0
            modified_files = test_files.map { |f| "-only-testing:#{test_target}/#{f}" }.join(",")
          end
        end

        def test_classes_with_paths(paths, test_paths)
          test_classes = paths.select{|path| path =~ TEST_FILE_REGEXP }   # get only Test/Spec
            .collect {|path| classname_with_file(path) }
          non_test_classes = paths.select{|path| path !=~ TEST_FILE_REGEXP }
            .collect {|path| test_file(path, test_paths) }
            .compact
            .collect {|path| classname_with_file(path) }
          test_classes = non_test_classes + test_classes
          test_classes.uniq
        end          
        
        # Example "ProjectName/Model/User+CoreDataExtensions.swift"
        # The first regex strips the file extension and the second removes 
        # any non alphanumeric characters.
        # The above example would return UserCoreDataExtensions so if a testing
        # file named UserCoreDataExtensions(Spec|Test).swift is found, we are
        # in business
        def classname_with_file(path)
          path.split("/").last.gsub(/(\.(.+))$|[^0-9a-z ]/i, "")
        end

        # Give a file and a test path, find the test for the given file in the test path.
        # return nil if the test do not exists.
        #
        def test_file(file, test_paths)
          test_paths = [] unless test_paths
          test_paths = [test_paths] unless test_paths.is_a?(Array)
          class_name = classname_with_file(file)
          # for each test path, check if we can find corresponding test file
          test_paths.each do |path|
            files = Dir.glob("#{path}/**/#{class_name}*.*").select {|file| file =~ /#{class_name}(Test|Spec)\.(m|swift)$/ }
            return files.first
          end
          return nil
        end
      end    
    end
  end
end
