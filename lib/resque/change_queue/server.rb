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
            erb File.read(Resque::ChangeQueue::Server.erb_path('change_queue.html.erb'))
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
