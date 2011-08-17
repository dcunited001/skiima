## First Gem
So Be Nice!

Very early version, still designing everything
Check out my project Skate for a idea of what it does

### Requirements
Skiima doesn't have any out of the ordinary dependencies.  It uses RSpec for testing and hooks into Rails.  I'm still thinking about how I want Skiima to interface with gems and other Ruby applications.

### Tests
At the moment, Skiima does not have any tests.  This will definitely change as I make more progress.  I'm also still thinking of the best way to test across all database platforms.  This should be interesting.

Right now Skiima is configured to test with RSpec, but I'm looking into MiniTest as I want something a little more lightweight.  If anyone could elaborate on the benefits of various test frameworks as they apply to gem development, please shoot me an email.

### Installation
1. Install the Skiima Gem.  Run `gem install skiima`
2. Run the install generator.  Run `rails generate skiima:install`
    * This does several things:
        * Adds the Skiima.rb Initializer to config/initializers
        * Creates the db/skiima folder, where your sql scripts will reside
        * Creates the db/skiima/skiima.yml file, which contains configuration options
        * Adds the en.yml locale file to config/locales/skiima.en.yml
        * And this adds a migration that is scheduled to run last
            * You can also break this up into several migrations if you want
3. After running the install generator, you will need to set up a few things:
    * You need to tell Skiima which classes have extra SQL objects
        * You specify this in the Skiima.yml file, where you can find examples
        * You can either simply specify "class_name:"
            * in this case, Skiima will take the default actions when creating and dropping objects for this class
        * Or you can specify "class_name: class_name.rb"
            * in this case, the depends:install generator will create the file specified
            * here you can customize the create and drop actions however you like
    * You can also add types of SQL objects supported by the database engine
        * this is going to take awhile to implement though
        * for now, this is just where you specify the default load order of object types
4. Now you can run the dependency generator.  Run `rails generate skiima:depends`
    * this will load the classes you specify in skiima.yml into depends:yml
        * and layout the default load order of objects
    * this will also create the custom "class_name.rb" files in db/skiima if you specified this
        * these classes all need to inherit from Skiima::LoaderBase
        * if these classes don't exist, Skiima dynamically creates them anyway
5. Your objects will be created when your migrations run.
    * You can also run a rake task to push your objects up.

#### (About half of ^^ that isn't written yet, but that's the interface)



