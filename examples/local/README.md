# Ruby Local Bucketing Example

## Setup

You will need Ruby and Ruby on Rails to run this app

### Installing Ruby

You can install a specific verion of Ruby via Homebrew or use a ruby version manager like [rbenv](https://github.com/rbenv/rbenv)

### Installing Rails

Once you have Ruby installed you'll be able to run `gem install rails` to install rails

## Running the app

In the root dirctory run `bundle install` to install required dependencies.

Run `DEVCYCLE_SERVER_SDK_KEY={sdk_key} bundle exec rails server` to start the rails server. The server should be running on `localhost:3000`

## Running With a Mocked Config

The Rails app can also be run with a mocked config by setting the `MOCK_CONFIG` environment variable to `true`. The test config can be can be found in `test_data/large_config.json`.

## Benchmarking

Start the app with a mocked config `MOCK_CONFIG=true bundle exec rails server`.

You can now benchmark the variable evaluation time by making a request to the `/variable` endpoint using an HTTP load generator such as [hey](https://github.com/rakyll/hey):

```bash
hey -n 500 -c 100 http://localhost:3000/variable 
```
