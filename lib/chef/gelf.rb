require "chef/gelf/version"
require 'gelf'
require 'chef/log'

class Chef
  module GELF
    class Handler < Chef::Handler
      attr_reader :notifier
      attr_reader :options
      
      def options=(value = {})
        @options = { :port => 12201, :facility => "chef_client", :blacklist => {}, :host => nil }.merge(value)
      end

      def initialize(options = {})
        self.options = options
        
        Chef::Log.debug "Initialised GELF handler for gelf://#{self.options[:server]}:#{self.options[:port]}/#{self.options[:facility]}"
        @notifier = ::GELF::Notifier.new(self.options[:server], self.options[:port], 'WAN', :facility => self.options[:facility])
      end

      def report
        Chef::Log.debug "Reporting #{run_status.inspect}"
        if run_status.failed?
          Chef::Log.debug "Notifying Graylog server of failure."
          @notifier.notify!(:short_message => "Chef run failed on #{node.name}. Updated #{changes[:count]} resources.",
                            :full_message => run_status.formatted_exception + "\n" + Array(backtrace).join("\n") + changes[:message],
                            :level => ::GELF::Levels::FATAL,
                            :host => host_name)
        else
          Chef::Log.debug "Notifying Graylog server of success."
          @notifier.notify!(:short_message => "Chef run completed on #{node.name} in #{elapsed_time}. Updated #{changes[:count]} resources.",
                            :full_message => changes[:message],
                            :level => ::GELF::Levels::INFO,
                            :host => host_name)
        end
      end
      
      protected
      def host_name
        options[:host] || node[:fqdn]
      end
      
      def changes
        @changes unless @changes.nil?
        
        lines = sanitised_changes.collect do |resource|
          "recipe[#{resource.cookbook_name}::#{resource.recipe_name}] ran '#{resource.action}' on #{resource.resource_name} '#{resource.name}'"
        end

        count = lines.size

        message = if count > 0
          "Updated #{count} resources:\n\n#{lines.join("\n")}"
        else
          "No changes made."
        end

        @changes = { :lines => lines, :count => count, :message => message }
      end

      def sanitised_changes
        run_status.updated_resources.reject do |updated|
          cookbook = @options[:blacklist][updated.cookbook_name]
          if cookbook
            resource = cookbook[updated.resource_name.to_s] || []
          else
            resource = []
          end
          cookbook && resource.include?(updated.action.to_s)
        end
      end
    end
  end
end
