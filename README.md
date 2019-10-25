# ShotgunApiRuby

A gem to integrate with shotgun REST API easily.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shotgun_api_ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shotgun_api_ruby

## Usage

### Client instantiation

For creating a new client you need to provide two values.

- One to identify the shotgun site:
  - Can be `shotgun_site`: which is the `xxx` part in `https://xxx.shotgunstudio.com`
  - Can be `site_url`: which is the full url to your site
- One to `auth` you see _Authentication_ lower in this guide.

Example:

```ruby
client = ShotgunApiRuby.new(shotgun_site: 'i-love-shotgun', auth: {client_id: 'my_nice_script', client_secret: 'CantTouchThis'})
```

### Authentication

Any kind of authentication specified [here](https://developer.shotgunsoftware.com/rest-api/#authentication) is implemented

#### Client Credentials

```ruby
client = ShotgunApiRuby.new(shotgun_site: 'xxx', auth: {client_id: 'script_name', client_secret: 'script_secret'})
```

#### Password Credentials

```ruby
client = ShotgunApiRuby.new(shotgun_site: 'xxx', auth: {username: 'login', password: 'password'})
```

#### Session Token

**We highly advise not using this for a long term script as this won't be a stable value over time**

```ruby
client = ShotgunApiRuby.new(shotgun_site: 'xxx', auth: {session_token: 'session_token'})
```

#### Refresh Token

**We highly advise not using this for a long term script as this won't be a stable value over time**

```ruby
client = ShotgunApiRuby.new(shotgun_site: 'xxx', auth: {refresh_token: 'refresh_token'})
```

### Entities

Querying entities is done by accessing the named method

```ruby
client.assets # => ShotgunApiRuby::Entities …
```

As entities can be user defined the client will try to answer to any unknown type with an entity call so any of those calls will returns the same thing:

```ruby
client.assets
client.asset
client.entities("Asset")
client.entities(:Assets)
```

### Entity

Returned entity will try to behave as nicely as possible.

An entity will always answer to:

- .type : the type of the entity
- .id : the id of the entity
- .relationships : a hash of relationships
- .links : a hash of links to other entities
- .attributes : An object answering to any available attributes

It will also answer to any method that is present in the attributes:

```ruby
assets = client.assets.all(fields: 'code')
assets.first.type # => "Asset"
assets.first.id # => 726
assets.first.attributes.code # => "Buck"
assets.first.code # => "Buck"
```

#### Get

##### all

The all call will return all possible entities.

```ruby
client.assets.all
```

##### fields

This attribute describe the wanted fields in the returned entity

Can be a string describing wanted fields: `'code'` or `'code,description'`
Or an array for better readability: `[:code, 'description']`

Example:

```ruby
client.assets.all(fields: [:code, :description])
```

##### sort

Describe how you want your entities to be sorted.

Can be either:

- A string: `'code'` or `'code,-description'` (the `-` asking for a descending order)
- An array for better readability: `[:code, '-description']`
- A hash for ease of use: `{code: 'asc', description: :desc}`

Example:

```ruby
client.assets.all(fields: [:code, :description], sort: {code: :asc, description: :desc})
```

##### filter

Not implemented yet

##### page

Not implemented yet

##### options

Not implemented yet

#### Create

Not implemented yet

#### Update

Not implemented yet

#### Delete

Not implemented yet

### Non implemented calls

All calls which are not yet implemented can be done through the `connection` method. This method will still take care of the authentication for you.

```ruby
client = ShotgunApiRuby.new(…)
client.connection.get('/entity/assets') # => #<Faraday::Response:xxx @on_complete_callbacks=[], @env=#<Faraday::Env @method=:get @body="{\"data\":[{\"type\":\"Asset\",\"attributes\":{},\"relationships\":{},\"id\":726 …
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Every commit/push is checked by overcommit.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shotgunsoftware/shotgun_api_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
