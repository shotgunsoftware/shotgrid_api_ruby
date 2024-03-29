# ShotgridApiRuby

[![Gem Version](https://badge.fury.io/rb/shotgrid_api_ruby.svg)](https://badge.fury.io/rb/shotgrid_api_ruby)
![Test and Release badge](https://github.com/shotgunsoftware/shotgrid_api_ruby/workflows/Test%20and%20Release/badge.svg)

A gem to integrate with shotgrid REST API easily.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shotgrid_api_ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shotgrid_api_ruby

## Usage

### Client instantiation

For creating a new client you need to provide two values.

- One to identify the shotgrid site:
  - Can be `shotgun_site`: which is the `xxx` part in `https://xxx.shotgunstudio.com`
  - Can be `shotgrid_site`: which is the `xxx` part in `https://xxx.shotgrid.autodesk.com`
  - Can be `site_url`: which is the full url to your site
- One to `auth` you see _Authentication_ lower in this guide.

Example:

```ruby
client = ShotgridApiRuby.new(shotgrid_site: 'i-love-shotgrid', auth: {client_id: 'my_nice_script', client_secret: 'CantTouchThis'})
```

### Authentication

Any kind of authentication specified [here](https://developer.shotgunsoftware.com/rest-api/#authentication) is implemented

#### Client Credentials

```ruby
client = ShotgridApiRuby.new(shotgrid_site: 'xxx', auth: {client_id: 'script_name', client_secret: 'script_secret'})
```

#### Password Credentials

```ruby
client = ShotgridApiRuby.new(shotgrid_site: 'xxx', auth: {username: 'login', password: 'password'})
```

#### Session Token

**We highly advise not using this for a long term script as this won't be a stable value over time**

```ruby
client = ShotgridApiRuby.new(shotgrid_site: 'xxx', auth: {session_token: 'session_token'})
```

#### Refresh Token

**We highly advise not using this for a long term script as this won't be a stable value over time**

```ruby
client = ShotgridApiRuby.new(shotgrid_site: 'xxx', auth: {refresh_token: 'refresh_token'})
```

### ShotgridCallError

Every ShotGrid call resulting in an error will throw a ShotgridCallError. This error class derive from StandardError and will implement 2 extra methods:
- `#response` => Will returns the original HTTP response (a Faraday::Response).
- `#status` => This method is a shortcut to get the status from the response.

exemple
```ruby
begin
  # A ShotGrid call resulting in a error
rescue StandardError => e
  p e.message, e.backtrace # Will behave as a normal StandardError
  p e.response.body # Original unparsed body from ShotGrid response
  p e.status # Status code from ShotGrid answer
end
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
client.assets # => ShotgridApiRuby::Entities …
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

### Search

#### all

The all call will return all possible entities.

```ruby
client.assets.all
```

#### search

Does the same thing as `all`

#### first

Will return only the first entity found (same thing as setting the page_size to 1 and then getting the first result)

```
client.assets.first
```

#### arguments

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

##### logical_operator

Default: "and"

This will be only used on complex queries. This is how we treat multiple first level conditions.

Accepted values: 'and', 'or'

##### filter

For simple filters, the filter field is waiting for a hash.

Each value is:

- A string: then a `is` filter will be used
- An array: then a `in` filter will be used

Example:

```ruby
client.assets.all(fields: [:code, :description], filter: {code: ['Buck', :Darcy], description: 'I LOVE SG'})
```

For complex filters, see the documentation [here](https://developer.shotgunsoftware.com/rest-api/#searching).

If the filters are complex there's many cases:

* If they are a hash containing logical_operator and conditions => we will use them
* If the filter is **not** a hash => we will use it without translation
* If the filter is a hash not containing "conditions". We will try to translate this to SG compatible query.

Example:
```ruby
client.assets.all(
  filter: {
    project: { id: 2 },
    sg_status_list: ["act", "hld", "omt"]
  }, 
)
# Will be translated to:
{
  "filters"=>{
    "conditions"=> [
      ["project.Project.id", "is", 2], 
      ["sg_status_list", "in", ["act", "hld", "omt"]]
     ], 
     "logical_operator"=>"and"
   }
}
```

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

### Finding one element

`find` function on `entities` allow you to get one element in particular.

It accepts (all arguments are optional):

- fields: string, symbol or array of fields
- retired: boolean specifying if the record is retired
- include_archived_projects: boolean specifying if the entity is part of an archived project

Example:

```ruby
client.assets.find(724, fields: [:code, 'description'], retired: false)
```

### Create

Will create the entity referenced by the id with the following fields. 
If successful, it will return the newly created entity.

```ruby
client.assets.create(code: 'New Asset', project: {type: 'Project', id: 63})
```

### Update

Will update the entity referenced by the id with the following fields. 
If successful, it will return the modified entity.

```ruby
client.assets.update(1226, code: 'Updated Asset', sg_status_list: 'fin')
```

### Delete

Will destroys the entity referenced by the id. Will return true if successful.

```ruby
client.assets.delete(1226)
```

### Revive

Will try to revive the entity referenced by the id. Will return true if successful.

```ruby
client.assets.revive(1226)
```

### Summarize

Will summarize data for an entity type.

Example:
```ruby
# Simplest example
client.assets.summarize(summary_fields: {id: :count})

# Full complex example
client.assets.summarize(
  filter: { project: { id: 122 }, sg_status_list: :act },
  logical_operator: 'or',
  include_archived_projects: true,
  grouping: {
    code: {direction: :desc, type: 'exact'}
  },
  summary_fields: { id: :count }
)

# Raw shotgrid queries
client.assets.summarize(
  grouping: [
    {
      "field": "sg_asset_type",
      "type": "exact",
      "direction": "asc"
    }
  ],
  summary_fields: [
    {
      "field": "id",
      "type": "count"
    }
  ],
)
```

It accepts the same `filter` and `logical_operator` as a `search` will.

#### Summary fields

Those can have two forms:

##### The normal API form

You need to supply the summary_fields as an array and it will be passed directly to the SG REST API

#### The convenient form

Using an array isn't very convenient most of the time. You can use a hash instead and it will be translated into a "SG summary_fields array".

Each key of the hash is the field name and the corresponding value is the type a summary you want (can be a string or a symbol)

#### Grouping

Those can have two forms:

##### The normal API form

You need to supply the grouping as an array and it will be passed directly to the SG REST API

#### The convenient form

Using an array isn't very convenient most of the time. You can use a hash instead and it will be translated into a "SG grouping array".

Each key of the hash is the field name and the corresponding value can either be :
* A String/Symbol and then will be used a a direction. The type will be 'exact'
* A Hash with optional 'type' and 'direction' keys. If a key is not specified it will be 'exact' and 'asc' respectively.

### Count

This is a helper for more a readable count summary. This can be passed `filter` and `logical_operator`.

Example:

```ruby
client.assets.count

# This will be equivalent as doing:
client.assets.summarize(summary_fields: [{type: :record_count, field: :id}])
```

### Schema

Those calls allow to inspect the schema for a shotgrid site.

#### Entity

```ruby
client.assets.schema
```

#### Entity fields

Fetch the different fields available on an entity type and their definition.

```ruby
fields = client.assets.fields
fields.code.name # => "Asset Name"
fields.code.properties.summary_default # => "none"
```

### Non implemented calls

All calls which are not yet implemented can be done through the `connection` method. This method will still take care of the authentication for you.

```ruby
client = ShotgridApiRuby.new(…)
client.connection.get('/entity/assets') # => #<Faraday::Response:xxx @on_complete_callbacks=[], @env=#<Faraday::Env @method=:get @body="{\"data\":[{\"type\":\"Asset\",\"attributes\":{},\"relationships\":{},\"id\":726 …
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Every commit/push is checked by overcommit.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shotgunsoftware/shotgrid_api_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
