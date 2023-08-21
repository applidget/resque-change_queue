# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/change_queue/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-change_queue"
  spec.version       = Resque::ChangeQueue::VERSION
  spec.authors       = ["rpechayr"]
  spec.email         = ["romain.pechayre@applidget.com"]
  spec.homepage      = "https://github.com/applidget/resque-change_queue"
  spec.summary = 'Reorganize queued jobs on the fly'
  spec.description = <<-DESCRIPTION
    Allows you to requeue jobs to another queue
    This is useful in my situations :
      - A large amount of jobs are queued in the critical queue, blocking the main queue for Several hours.
      Select jobs based on criteria and requeue them to the low queue
  DESCRIPTION
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug", "~> 9.0"

  spec.add_runtime_dependency 'redis', '< 6'
  spec.add_runtime_dependency 'resque', '>= 1.25', '< 3'
end
