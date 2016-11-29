require 'guard/compat/plugin'
require_relative './xcodebuild/version'
require_relative './xcodebuild/notifier'
require_relative './xcodebuild/options'
require_relative './xcodebuild/util'

module Guard
  class Xcodebuild < Plugin
    attr_reader :options, :notifier

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
      @options = Options.with_defaults(options)                  
      @notifier = Notifier.new(@options)   
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

      # unless system("which #{notifier}") || disable_notifier == true      
      #   UI.error "#{notifier} not found, please install it or disable the notifier by adding the disable_notifier option to your Guardfile"
      #   throw :task_has_failed
      # end

      unless options[:test_target]
        UI.error "Cannot find test target, please specify :test_target option"
        throw :task_has_failed
      end
      
      Compat::UI.info "Guard::Xcodebuild is running"
      run_all if options[:all_on_start]      
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
      _really_run(Util.xcodebuild_command(options))
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
      UI.info "Running tests on modified paths: #{paths}"      
      _really_run(Util.xcodebuild_command(options.merge(modified_paths: paths)))
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

    def _really_run(command)
      UI.info("Running: #{command}")
      result = system(command)
      if result == true
        @notifier.notify("All tests passed")
      else
        @notifier.notify_failure      
        throw :task_has_failed
      end
    end
    
  end
end
