require "guard/xcodebuild/version"
require 'guard/compat/plugin'
require_relative './xcodebuild_util'

module Guard
  class Xcodebuild < Plugin
    include XcodebuildUtil
    attr_reader :test_paths, :test_target, :file_args, :args, :all_on_start, :notifier, :disable_notifier

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      super
      @file_args = load_args      
      @args = options[:args]
      @test_paths = options[:test_paths]    || "."
      @test_target = options[:test_target]  || find_test_target
      @all_on_start = options[:all_on_start] || false
      @notifier = options[:notifier] || "terminal-notifier"   
      @disable_notifier = options[:disable_notifier] || false   
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
      unless system("which xcodebuild")
        UI.error "xcodebuild not found, please install Xcode then try again"
        throw :task_has_failed
      end

      unless system("which #{notifier}") || disable_notifier == true      
        UI.error "#{notifier} not found, please install it or disable the notifier by adding the disable_notifier option to your Guardfile"
        throw :task_has_failed
      end

      unless test_target
        UI.error "Cannot find test target, please specify :test_target option"
        throw :task_has_failed
      end
      
      run_all if all_on_start      
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
      UI.info "Running all tests..."
      xcodebuild_command
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
      test_files = test_classes_with_paths(paths, test_paths)
      if test_files.size > 0
        modified_files = test_files.map { |f| "-only-testing:#{test_target}/#{f}" }.join(",")
        UI.info "Running tests on classes: #{modified_files}"
        xcodebuild_command("#{modified_files}")
      else
        run_all
      end
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
    end    

    private

    def xcodebuild_command(command = nil)
      # Pipefail is required so the xcpretty pipe doesnt swallow xcodebuild errors
      commands = ["set -o pipefail; xcodebuild test"]  
      commands << file_args if file_args && file_args.strip != ""
      commands << args if args && args.strip != ""
      commands << command if command && command.strip != ""
      commands << "| xcpretty"
      final_command = commands.join(" ")
      UI.info("Running xcodebuild: #{final_command}")
      xcodebuild_test_result = system(final_command)
      unless disable_notifier == true
        notification_message = xcodebuild_test_result == true ? "All tests passed" : "One or more tests have failed"
        system("terminal-notifier -message #{notification_message}")
      end
      throw :task_has_failed if xcodebuild_test_result == false
    end
  end
end
