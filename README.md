Skiima: an ORM-Agnostic, Rails-Independent alternative to migrations.

[![Build Status](https://travis-ci.org/dcunited001/skiima.png?branch=master)](https://travis-ci.org/dcunited001/skiima)

------------------------

## Using Skiima with ActiveRecord:

> Adding generators soon

#### Installing
1. Add skiima to your Gemfile
1. Bundle Install
1. Configure your database.yml
  - Ensure that users have the appropriate DDL permissions
1. `mkdir db/skiima`
1. `touch db/skiima/dependencies.yml`
  - Refer to the example below or $SKIIMA_GEM/spec/db/skiima/dependencies
1. Set up a :test dependency group
  - include the groups of scripts you want to run after a fresh db clone
  - add `bundle exec rake skiima:test:up` to your CI setup script, after calling db:test:prepare
  - or add a rake task to your project that calls both db:test:prepare and skima:test:up
  - specify environment/groups with `bundle exec rake skiima:test:up[development,group_name]
1. Set up a :default dependency group
  - include the groups of scripts you want to run during every deploy
  - because the scripts are run on each deploy, this rake task should only be used in certain instances
  - you should usually call Skiima.up & Skiima.down from a migration

#### Adding a new Skiima Script Group to your project

> Again, generators coming soon to help automate this.

1. Add a new migration to your Rails project.  Refer to the sample below.
1. `mkdir db/skiima/$group_name`
1. `touch db/skiima/$group_name/$type.$object_name.$db_type.$db_version.sql`
  - $type => view/proc/function/etc
  - $object_name => identifies the script across multiple db providers & versions
  - $db_type => provider name (mysql/postgres)
  - $db_version => usually just 'current'
    - using $db_version, you can write scripts to support multiple versions of mysql, for example
    - Skiima compares the connected database's version to pull the correct script
    - or you can just configure skiima to prefer to load specific version of sql scripts
    - pass :version => 'version_name' to Skiima.up & Skiima.down
1. Also add a corresponding drop script to run if:
  - either the up script is not reversible with a single drop statement
  - or if Skiima can not automatically drop that type object
  - see below for supported objects
1. Now update db/skiima/dependencies.yml
  - Refer to the example below or $SKIIMA_GEM/spec/db/skiima/dependencies
1. The script should be ready to use with Skiima.up & Skiima.down

Sample Skiima Migration:

```ruby

class AddViewBackedModel < ActiveRecord::Migration
  def up
    Skiima.up(Rails.env, :group_name)
  end

  def down
    Skiima.down(Rails.env, :group_name)
  end
end

```

Sample Dependencies.yml:

```yml

script_group_name:
  postgresql:
    current:
      - view.script_name
  mysql:
    current:
      - view.script_name
dependency_group_name:
  - script_group_name

# load/drop these script groups with:
#   `rake skiima:up` & `rake skiima:down`
# List migrations you have already squashed
# - IE migrations that you removed to rely on schema.rb
default:
- script_group_a
- script_group_b
- script_group_c

# load/drop these script groups with:
#   `rake skiima:test:up` & `rake skiima:test:down`
# For tests/CI!
# List migrations that need to be run after a blank db is migrated
# - IE migrations that you squashed, if you are migrating from scratch on CI
# - If relying on db/schema.rb for CI, then list the groups you need for tests
test:
- script_group_a
- script_group_b
- script_group_c

```

#### Running tests with your new Skiima Script Group

1. `bundle exec rake db:migrate`
1. `bundle exec rake db:test:prepare`
1. `bundle exec rake skiima:test:up`
1. `bundle exec rake`

#### Adding a view-backed model

```ruby
# add a view named 'view_foo_report_on_bar'
class FooReportOnBar < ActiveRecord::Base
  set_table_name :view_foo_report_on_bar

  belongs_to :baz
end
```

## Using Skiima with another ORM:

> Support for Datamapper, Sequal, & JRuby providers coming soon.

## Running Tests

1. Setup Mysql & Postgres. I recommend copying Procfile.example and using foreman.
1. Copy database.yml.example & set up users/passwords for your system
  - configure an existing user/password for postgresql_root & mysql_root
  - this user creates a user for the test databases in the rake setup tasks
1. `bundle install`
1. `appraisal install`
1. Run test setup tasks
  - `rake skiima:setup:db:postgresql`
  - `rake skiima:setup:db:mysql`
    - you may need to remove the `DROP USER` command in `spec/db/skiima/init_test_db/database.skiima_test.mysql.current.sql`
1. `appraisal activerecord-3.2 rake`
  - to test with activerecord-4.0, use that appraisal set
  - or `appraisal rake` to run them with all appraisal sets

## Skiima Goals:
* Provide a better way to integrate views and functions into Ruby applications.
* Embeddable in gems to create DB independent extensions.
* Avoid any unnecessary dependencies or complexity.

I was working on another project and added some cool features that relied on postgres views, rules, etc.  And basically, I needed a place to put these scripts and a way to execute them in a specified order.

There are alot of cool tricks to use in ActiveRecord with sql objects other than tables.  Not to mention there are performance benefits with the right schema.  Not everything needs to happen at the application layer.

If you have any questions about how things work, look at the tests.  If you have any suggestions, don't hesitate to contact me.

## Supported Databases:
#### Postgres

- Schemas
- Tables
- Indexes
- Views
- Rules
- Triggers(soon)
- Functions(soon)

#### Mysql/Mysql2

- Tables
- Views
- Indexes
- Triggers(soon)
- Functions(soon)
- Procs(soon)

## Interface:
#### Config Files
Skiima reads two yaml files: database.yml and dependencies.yml.

- By default, `database.yml` goes in your `APP_ROOT/config directory`.
- And similarly, `dependencies.yml` goes in `APP_ROOT/db/skiima`.

#### Groups
Skiima allows you to create groups of sql scripts to be executed during migrations.  Each group of sql scripts requires its own folder inside `db/skiima`.

#### Adapter and Version
Since different databases have different capabilities and object types, you can trigger different scripts to run per adapter.  Furthermore, you can execute different scripts for different versions of a database.  You can also use this version tag if you want to package different sets of functionality.

#### Dependencies.yml Format
In the `dependencies.yml` configuration, add lines for each script in the format.

* `type.name.attr1.attr2`

`attr1` and `attr2` allow you to define the target SQL object and other attributes that need to be passed on a per type basis.  This is only used when Skiima drops your objects without a matching 'drop' script.

#### Filename Format
Inside each group folder, create sql files with the following format.  These need to match the `dependencies.yml` configuration.

* `type.name.adapter.version.sql`
* `type.name.adapter.version.drop.sql` to override the default drop behavior.

#### Interpolation in Scripts
You can interpolate variables in your SQL Scripts and then pass in values at runtime with the `:vars` hash.  The default character to use for interpolation is `&`, but this can be changed in the Module initialization.  There are default vars that are substituted, such as `&database`.

#### Module Initialization
If you're using Rails, you can add a Skiima.setup block in an intializer file to set defaults.  There are other ways to integrate Skiima into your project as well.

    Skiima.setup do |config|
      config.root_path = Rails.root # changing
      config.config_path = 'config'
      config.scripts_path = 'db/skiima'
      config.locale = :en
    end

#### Finally, in your Migrations
Skiima reads the specified groups from dependencies.yml and compiles a list of scripts to run.  If you're using Rails, substitute `:development` with `Rails.env`

    def up
      Skiima.up(:development, :group_one, :group_n, :vars => {:var_one => 'db_name'})
    end

    def down
      Skiima.down(:development, :group_one, :group_n, :vars => {:var_one => 'db_name'})
    end

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

## 0.2.011 Updates:

- Add Travis CI Config
- Add Railties tasks
- Updated dependencies.yml to allow for dependency groups
- Updated Readme with examples

## 0.2.100 Planned:

- Add JRuby Support
- Add Appraisal to test Skiima with separate bundles
- Add Coveralls?
- Add Gemnasium?

## 0.3 Planned:

- DataMapper Support
- Sequel Support
- Mongo Support?
- Manage config's for other data providers? (Redis/etc)
