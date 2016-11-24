require 'xcodeproj'
require 'JSON'

module Guard
  module XcodebuildUtil
    TEST_FILE_REGEXP = /(Test|Spec)\.(m|swift)$/
    XCODEBUILD_ARGS = '.xcodebuild-args'
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

    # Find first project and first Test target from current folder
    def find_test_target   
      project_name = Dir["*.xcodeproj"].first
      if project_name
        project = Xcodeproj::Project.open(project_name)
        # find first targets with name ends with Spec(s) or Target(s)
        return project.targets.collect(&:name).find {|f| f =~ /(Spec|Test)s?$/}
      end
    end

    def load_args
      return unless File.file?(XCODEBUILD_ARGS)
      if f = File.open(XCODEBUILD_ARGS)
        args = JSON.parse(f.read)
        parse_args(args)
      end
    end

    protected

    # Example "ProjectName/Model/User+CoreDataExtensions.swift"
    # The first regex strips the file extension and the second removes 
    # any non alphanumeric characters.
    # The above example would return UserCoreDataExtensions so if a testing
    # file named UserCoreDataExtensions(Spec|Test).swift is found, we are
    # in business
    def classname_with_file(path)
      path.split("/").last.gsub(/(\.(.+))$|[^0-9a-z ]/i, "")
    end

    private

    def parse_args(args)      
      s = ""
      args.keys.each { |k| s = s + "-#{k} #{args[k]} " }
      return s
    end

  end
end
