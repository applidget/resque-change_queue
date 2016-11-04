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

  context "when querying a queue based on parameters" do
    it "outputs exactly 100 jobs when parameter not specified" do
      103.times do
        Resque.enqueue SomeJob, "other", "two"
      end
      results = Resque::ChangeQueue.search_jobs(:main, SomeJob)
      expect(results.count).to eq(100)
    end

    it "outputs only 10 jobs" do
      11.times do
        Resque.enqueue SomeJob, "other", "two"
      end
      results = Resque::ChangeQueue.search_jobs(:main, SomeJob, [], 0 , 10)
      expect(results.count).to eq(10)
    end

    it "outputs only jobs with the right class" do
      876.times do |cpt|
        Resque.enqueue SomeOtherJob, "other", cpt
      end

      10.times do |cpt|
        Resque.enqueue SomeJob, "other", "so ?"
      end

      results = Resque::ChangeQueue.search_jobs(:main, SomeJob)
      expect(results.count).to eq(11)
    end

    it "outputs only jobs with right class + matching params" do
      876.times do |cpt|
        Resque.enqueue SomeOtherJob, "other", cpt
      end

      10.times do |cpt|
        Resque.enqueue SomeJob, "other", "so ?"
      end

      28.times do |cpt|
        Resque.enqueue SomeJob, "other", "match"
      end

      results = Resque::ChangeQueue.search_jobs(:main, SomeJob, ["other"])
      expect(results.count).to eq(38)

      results = Resque::ChangeQueue.search_jobs(:main, SomeJob, ["other", "match"])
      expect(results.count).to eq(28)

    end
  end


end
