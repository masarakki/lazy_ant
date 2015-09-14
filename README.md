# LazyAnt

LazyAnt is a generator of client for any apis.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lazy_ant'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lazy_ant

## Usage

define your api client:

```ruby
require 'my_api_client/user'

class MyApiClient
  include LazyAnt::DSL

  # specify configurable
  configurable :client_token, default: ''
  configurable :client_secret, default: ''
  configurable :dev?, default: false

  base_url 'https://myapi.example.com'
  # or
  base_url { config.dev? ? 'http://devapi.example.com' : 'https://myapi.example.com' }

  # setup faraday connection
  connection do |con|
    con.headers['X-client-token'] = config.client_token
    con.user_agent = 'my-api-client ver. 0.1'
  end

  group :user do
    api :find, get: '/users/:id.json', entity: :User
    api :search, get: '/users/search.json', multi: true, entity: :User
  end
end
```

and use it:

```ruby
client = MyApiClient.new do |config|
  config.client_token = 'hello'
  config.client_secret = 'world'
end

client.user.find(1)
# => MyApiClient::User

client.user.search(q: 'hello')
# => [MyApiClient::User, MyApiClient::User, ...]
```

you can configure with class methods:

```ruby
# such as in config/initializers/my_api_client.rb
MyApiClient.setup do |config|
  config.client_token = 'hello'
  config.client_secret = 'world'
end

# use in other file
client = MyApiClient.new
client.user.get(1)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/masarakki/lazy_ant. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
