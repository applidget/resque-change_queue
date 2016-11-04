require "resque/change_queue/version"
require "resque"
require 'resque/server'

module Resque
  module ChangeQueue
    module_function
    def change_queue(from_queue, to_queue, klass, args = [])
      tmp_queue = "operation:#{SecureRandom.uuid}"
      moved_count = 0
      while job = Resque.pop(from_queue)
        target_queue = tmp_queue
        if job["class"] == klass.to_s && match_args(job["args"], args)
          target_queue = to_queue
          moved_count += 1
        end
        Resque.push(target_queue, job)
      end

      while job = Resque.pop(tmp_queue)
        Resque.push(from_queue, job)
      end

      # Finally ensure queue is removed
      Resque.remove_queue(tmp_queue)
      moved_count
    end

    def search_jobs(queue, klass, args = [], start = 0, count = 100)
      matched_jobs = []
      has_next = true
      while has_next
        page = Resque.peek(queue, start, 100)
        page.each do |job|
          next unless job["class"] == klass.to_s
          matched_jobs << job if match_args(job["args"], args)
          break if matched_jobs.count >= count
        end
        break if matched_jobs.count >= count
        has_next = (page != nil &&  page.count == 100)
        start += 100
      end
      matched_jobs
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
require 'resque/change_queue/server'
