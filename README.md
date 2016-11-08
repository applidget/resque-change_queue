# Resque ChangeQueue
[![Build Status](https://travis-ci.org/applidget/resque-change_queue.svg?branch=master)](https://travis-ci.org/applidget/resque-change_queue)

Resque ChangeQueue is a [Resque](https://github.com/resque/resque) plugin allowing you to move jobs from one queue to another. This can be useful in some situation where some queue can be unexpectedly filled with thousands of slow jobs to isolate them in a low queue in order not to block normal jobs.

Jobs can be queried based on their Class name and parameters.

Requeuing is done in a smart way such that you are 100% sure not to loose any job:
- The entire source queue is flushed (using `redis.pop`)
- Matched jobs are queued to the target queue directly
- Un matched jobs are queued to a temporay queue dedicated to the operation
- Finally all jobs in the temporary queue are requeued in the source queue

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque-change_queue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-change_queue

## Usage from the UI

This plugin is primarly built to enable manual jobs manipulation from resque web interface (native resque 1.x sinatra web interface). When including the gem into your Gemfile, you'll create a new tab in resque UI. You can filter the jobs from here, and then validate.
![](https://s3-eu-west-1.amazonaws.com/assets.applidget.com/documentation/change-queue-home.png)

You can add as many args in this step, and jobs will be matched based on strict equality of each parameter. If you specify less parameters than the number of parameters in the target jobs, additional parameters will be considered as matching. This allows you to filter jobs assuming that the first arguments are top level object ids (for example if your args are `[project_id, discussion_id, comment_id]`).

The next screen show you the first 100 jobs matching your criteria. Just pick a target queue and validate, you're done!

![](https://s3-eu-west-1.amazonaws.com/assets.applidget.com/documentation/change-queue-jobs.png)


## Usage from code

You can call Resque ChangeQueue from a console or from code :
```ruby
Resque::ChangeQueue.change_queue(source_q, target_q, "SomeJobClass", args)
```

*Note*: `args` is an optional parameter.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/applidget/resque-change_queue. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
