require 'yaml'

# Extends Resque Web Based UI.
# Structure has been borrowed from ResqueCleaner.
module Resque
  module ChangeQueue
    module Server

      def self.erb_path(filename)
        File.join(File.dirname(__FILE__), 'server', 'views', filename)
      end

      def self.public_path(filename)
        File.join(File.dirname(__FILE__), 'server', 'public', filename)
      end

      def self.included(base)

        base.class_eval do
          get "/changequeue" do
            erb File.read(Resque::ChangeQueue::Server.erb_path('search.html.erb'))
          end

          get "/changequeue/jobs" do
            klassname = params[:classname]

            #Process args to remove all tailing blank ones
            args = params[:args].keys.reverse
            while args.count > 0 && args[0].try(:length) > 0
              args.shift
            end
            args = args.reverse!
            jobs = Resque::ChangeQueue.search_jobs(params[:queue], klassname, args)
            erb File.read(Resque::ChangeQueue::Server.erb_path('jobs.html.erb')),{}, jobs: jobs
          end
        end

      end

      Resque::Server.tabs << 'ChangeQueue'
    end
  end
end

Resque::Server.class_eval do
  include Resque::ChangeQueue::Server
end
