require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard
  class Handlebars < Guard

    autoload :Formatter, 'guard/handlebars/formatter'
    autoload :Inspector, 'guard/handlebars/inspector'
    autoload :Runner, 'guard/handlebars/runner'
    autoload :Template, 'guard/handlebars/template'

    def initialize(watchers = [], options = {})
      watchers = [] if !watchers
      watchers << ::Guard::Watcher.new(%r{#{ options[:input] }/(.+\.handlebars)}) if options[:input]

      super(watchers, {
          :bare => false,
          :shallow => false,
          :hide_success => false,
          :compiled_name => 'compiled.js',
          :emberjs => false,
          :all_on_start => false,
      }.merge(options))
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def start
      run_all if options[:all_on_start]
    end
    
    def run_all
      run_on_change(Watcher.match_files(self, Dir.glob(File.join('**', '*.handlebars'))))
    end

    def run_on_change(paths)
      changed_files = Runner.run(Inspector.clean(paths), watchers, options)
      notify changed_files
    end
    
    # Called on file(s) deletions that the Guard watches.
    #
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_removals(paths)
      Runner.remove(Inspector.clean(paths, :missing_ok => true), watchers, options)
    end

    private

    def notify(changed_files)
      ::Guard.guards.each do |guard|
        paths = Watcher.match_files(guard, changed_files)
        guard.run_on_change paths unless paths.empty?
      end
    end

  end
end
