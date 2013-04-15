Skiima: an ORM-Agnostic, Rails-Independent alternative to migrations.

[![Build Status](https://travis-ci.org/dcunited001/skiima.png?branch=master)](https://travis-ci.org/dcunited001/skiima)

------------------------

## 0.2.000 Updates:

- Added a modified OpenStruct to manage configuration
- Moved most classes to separate files

## 0.2.010 Updates:

- Add Skiima::Db::Connector
- Update Skiima::Db::Resolver
- Add ActiveRecord::BaseConnector
- Add PosgresqlConnector
- Add Postresql Helpers
- Add MysqlConnector
- Add Mysql2Connector
- Add Mysql Helpers

## 0.2.011 Planned:

- Add Appraisal to test Skiima with separate bundles
- Fix Travis CI Config
- Add Coveralls?
- Add Gemnasium?

## 0.2.100 Planned:

- Add JRuby Support

## 0.3 Planned:

- DataMapper Support
- Sequel Support
- Mongo Support?
- Manage config's for other data providers? (Redis/etc)

#### Goals:
Skiima is a work in progress with the following goals:

* Provide a better way to integrate views and functions into Ruby applications.
* Embeddable in gems to create DB independent extensions.
* Avoid any unnecessary dependencies or complexity.

I was working on another project and added some cool features that relied on postgres views, rules, etc.  And basically, I needed a place to put these scripts and a way to execute them in a specified order.

There are alot of cool tricks to use in ActiveRecord with sql objects other than tables.  Not to mention there are performance benefits with the right schema.  Not everything needs to happen at the application layer.

If you have any questions about how things work, look at the tests.  If you have any suggestions, don't hesitate to contact me.

#### Supported Databases:
##### Postgres

- Schemas
- Tables
- Indexes
- Views
- Rules
- Triggers(soon)
- Functions(soon)

##### Mysql/Mysql2

- Tables
- Views
- Indexes
- Triggers(soon)
- Functions(soon)
- Procs(soon)

#### Interface:
##### Config Files
Skiima reads two yaml files: database.yml and dependencies.yml.

- By default, `database.yml` goes in your `APP_ROOT/config directory`.
- And similarly, `dependencies.yml` goes in `APP_ROOT/db/skiima`.

##### Groups
Skiima allows you to create groups of sql scripts to be executed during migrations.  Each group of sql scripts requires its own folder inside `db/skiima`.

##### Adapter and Version
Since different databases have different capabilities and object types, you can trigger different scripts to run per adapter.  Furthermore, you can execute different scripts for different versions of a database.  You can also use this version tag if you want to package different sets of functionality.

##### Dependencies.yml Format
In the `dependencies.yml` configuration, add lines for each script in the format.

* `type.name.attr1.attr2`

`attr1` and `attr2` allow you to define the target SQL object and other attributes that need to be passed on a per type basis.  This is only used when Skiima drops your objects without a matching 'drop' script.

##### Filename Format
Inside each group folder, create sql files with the following format.  These need to match the `dependencies.yml` configuration.

* `type.name.adapter.version.sql`
* `type.name.adapter.version.drop.sql` to override the default drop behavior.

##### Interpolation in Scripts
You can interpolate variables in your SQL Scripts and then pass in values at runtime with the `:vars` hash.  The default character to use for interpolation is `&`, but this can be changed in the Module initialization.  There are default vars that are substituted, such as `&database`.

##### Module Initialization
If you're using Rails, you can add a Skiima.setup block in an intializer file to set defaults.  There are other ways to integrate Skiima into your project as well.

    Skiima.setup do |config|
      config.root_path = Rails.root # changing
      config.config_path = 'config'
      config.scripts_path = 'db/skiima'
      config.locale = :en
    end

##### Finally, in your Migrations
Skiima reads the specified groups from dependencies.yml and compiles a list of scripts to run.  If you're using Rails, substitute `:development` with `Rails.env`

    def up
      Skiima.up(:development, :group_one, :group_n, :vars => {:var_one => 'db_name'})
    end

    def down
      Skiima.down(:development, :group_one, :group_n, :vars => {:var_one => 'db_name'})
    end

#### yes, i know i am shamelessly biting activerecord code.
