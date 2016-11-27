require 'xcodeproj'
require 'json'

module Guard
  module XcodebuildUtil
    TEST_FILE_REGEXP = /(Test|Spec)\.(m|swift)$/
    XCODEBUILD_ARGS_FILE = '.xcodebuild-args'
    # Find test class from input paths.
    # 
    # - if the path is end with Test.m/Test.mm/Spec.m/Spec.mm, then it is a test class, return the class name of it
    #
    # @param [Array<String>] paths
    # @param [Array<String>] test_path
    #
    def test_classes_with_paths(paths, test_path=[])
      test_classes = paths.select{|path| path =~ TEST_FILE_REGEXP }   # get only Test/Spec
        .collect {|path| classname_with_file(path) }
      non_test_classes = paths.select{|path| path !=~ TEST_FILE_REGEXP }
        .collect {|path| test_file(path, test_path) }
        .compact
        .collect {|path| classname_with_file(path) }
      test_classes = non_test_classes + test_classes
      test_classes.uniq
    end    

    # Find first project and first Test target from current folder
    def find_test_from_target_names(targets)
      targets.find {|f| f =~ /(Spec|Test)s?$/}
    end

    def load_args(json_string)      
      begin
        args = JSON.parse(json_string)
      rescue          
      end   
      parse_args(args) unless args.nil?     
    end

    protected

    def read_args_from_file
      return unless File.file?(XCODEBUILD_ARGS_FILE)
      f.read if f = File.open(XCODEBUILD_ARGS_FILE)
    end
      
    def get_first_project_target_names      
        xcode_projects_in_current_dir.targets.collect(&:name)
    end

    def xcode_projects_in_current_dir
      if project_name = Dir["*.xcodeproj"].first
        Xcodeproj::Project.open(project_name)
      end
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
    def test_file(file, test_paths=[])
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

    def parse_args(args)      
      s = ""
      args.keys.each { |k| s = s + "-#{k} #{args[k]} " }
      return s.strip
    end

  end
end
