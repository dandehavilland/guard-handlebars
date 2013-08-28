module Guard
  class Handlebars
    module Inspector
      class << self
        
        def clean(paths, options = {})
          paths.uniq!
          paths.compact!
          paths.select { |p| handlebars_file?(p, options) }
        end
        
        private
        def handlebars_file?(path, options)
          path =~ /.handlebars$/ && (options[:missing_ok] || File.exists?(path))
        end
      end
    end
  end
end
