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

### Server Infos

Get general server infos:

```ruby
client.server_info.get

#  #<OpenStruct
      shotgun_version="v8.6.0.0-dev (build 12864de)",
      api_version="v1",
      shotgun_version_number="8.6.0.0-dev",
      shotgun_build_number="12864de",
      portfolio_version="UNKNOWN",
      unified_login_flow_enabled=true,
      user_authentication_method="default">
```

### Preferences

Get some preferences infos:

```ruby
prefs = client.preferences.get
prefs.to_h.keys

# [:format_date_fields,
# :date_component_order,
# :format_time_hour_fields,
# :format_currency_fields_display_dollar_sign,
# :format_currency_fields_decimal_options,
# :format_currency_fields_negative_options,
# :format_number_fields,
# :format_float_fields,
# :format_float_fields_rounding,
# :format_footage_fields,
# :support_local_storage,
# :view_master_settings,
# :duration_units,
# :hours_per_day,
# :last_day_work_week]
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

Any not yet implemented call can be accessed through the connection: `client.assets.connection`

#### Entity

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

##### search

Does the same thing as `all`

##### first

Will return only the first entity found (same thing as setting the page_size to 1)

```
client.assets.first
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

For simple filters, the filter field is waiting for a hash.

Each value is:

- A string: then a `is` filter will be used
- An array: then a `in` filter will be used

Example:

```ruby
client.assets.all(fields: [:code, :description], filter: {code: ['Buck', :Darcy], description: 'I LOVE SG'})
```

For complex filters, see the documentation [here](https://developer.shotgunsoftware.com/rest-api/#searching)

The complexity of calling a different route and passing different headers/body/params will be taken care of automatically.

##### page

You can ask for any page size or page number.

- `page`: set the page number.
- `page_size`: set the size of each page.

Any of the two can be omited. Their type should be a number but it'll work with a string

Example:

```ruby
client.assets.all(fields: [:code], page: 3, page_size: 10)
client.assets.all(fields: [:code], page: '3')
client.assets.all(fields: [:code], page_size: 10)
```

##### options

Special options can be added:

- retired: a flag telling if the returned entities should be retired or not
- include_archived_projects: a flag telling if the archived projets should be included int the search

Example:

```ruby
client.assets.all(fields: [:code], retired: true)
client.assets.all(fields: [:code], include_archived_projects: true)
```

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
