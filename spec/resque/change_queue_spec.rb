require 'spec_helper'
require "resque"
require "resque/change_queue"

class SomeJob
  @queue = :main
  def self.perform(arg1, arg2)
  end
end

class SomeOtherJob
  @queue = :main

  def self.perform(arg1,arg2)
  end
end

describe Resque::ChangeQueue do
  before(:each) do
    Resque.enqueue SomeJob, "one", "two"
  end

  context "when no other job is present" do
    it "moves 1 job from one queue to another" do
      Resque::ChangeQueue.change_queue(:main, :low, SomeJob)
      expect(Resque.size(:main)).to eq(0)
      expect(Resque.size(:low)).to eq(1)
    end

    it "removes the tmp queue after job is done" do
      Resque::ChangeQueue.change_queue(:main, :low, SomeJob)
      debugger
      expect(Resque.queues.count).to eq(2)
    end
  end

  context "when other jobs are present in source queue" do
    it "does not move other jobs" do
      Resque.enqueue SomeOtherJob, "one", "two"
      Resque::ChangeQueue.change_queue(:main, :low, SomeJob)
      expect(Resque.size(:main)).to eq(1)
      expect(Resque.size(:low)).to eq(1)
    end
  end

  context "when filters are used" do
    it "moves only those whose parameters match filters" do
      Resque.enqueue SomeJob, "one", "three"
      Resque::ChangeQueue.change_queue(:main, :low, SomeJob, ["one", "two"])
      expect(Resque.size(:main)).to eq(1)
      expect(Resque.size(:low)).to eq(1)
    end

    it "moves jobs even if one argument filtered and more arguments in jobs" do
      Resque.enqueue SomeJob, "other", "two"
      Resque::ChangeQueue.change_queue(:main, :low, SomeJob, ["one"])
      expect(Resque.size(:main)).to eq(1)
      expect(Resque.size(:low)).to eq(1)
    end

    it "moves jobs filtered by second argument" do
      Resque.enqueue SomeJob, "other", "two"
      Resque::ChangeQueue.change_queue(:main, :low, SomeJob, [nil, "two"])
      expect(Resque.size(:main)).to eq(0)
      expect(Resque.size(:low)).to eq(2)
    end

  end


end
