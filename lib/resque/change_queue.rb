require "resque/change_queue/version"
require "resque"

module Resque
  module ChangeQueue
    module_function
    def change_queue(from_queue, to_queue, klass, args = [])
      tmp_queue = "operation:#{SecureRandom.uuid}"
      while job = Resque.pop(from_queue)
        target_queue = tmp_queue
        if job["class"] == klass.to_s && match_args(job["args"], args)
          target_queue = to_queue
        end
        Resque.push(target_queue, job)
      end

      while job = Resque.pop(tmp_queue)
        Resque.push(from_queue, job)
      end
    end

    def match_args(job_args, criteria_args)
      match = true
      criteria_args.each_with_index do |item, index|
        next if item.nil?
        if job_args[index] != item
          match = false
          break
        end
      end
    end
  end
end
