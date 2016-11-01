require "spec_helper"

describe Resque::ChangeQueue do
  it "has a version number" do
    expect(Resque::ChangeQueue::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
