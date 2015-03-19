# Baseline Ruby hosting performance

This script measures and compares baseline performance of Ruby hosting solutions.

Currently the following setups are supported:

- localhost with one puma (to make sure everything is in order)
- Heroku with puma web servers
- Shelly Cloud with puma web servers

## Quick Start

1. Install requirements:
   - [ab tool](http://httpd.apache.org/docs/2.4/programs/ab.html)
   - [heroku toolbelt](https://toolbelt.heroku.com/)
   - [shelly gem](https://shellycloud.com/documentation/shelly_gem)
2. Run `bundle install`.
3. Login to Heroku and to Shelly Cloud using their command line tools (`heroku auth:login` and `shelly login`).
4. Check out options by running `ruby measure-performance.rb --help`.
5. Run the benchmark with `ruby measure-performance.rb`.

## Structure of the code base

- `app/` contains the application that will be benchmarked. Currently it's a simple sinatra app with slim templates.
- `lib/` contains libraries and helpers for the benchmarking script.
- `measure-performance.rb` contains the benchmark script itself.
- `data/` will contain results of the benchmarking.

## Extending the script

Code is written in a way so as to make it easy to test different types of applications and different cloud solutions. Some starting points:

- Experiment with different configurations. For example you could rerun the test with different concurrency settings. That only requires using a proper comman line option.
- Modify the application under test. For example it could take a random time to respond, use file system or connect to a database. All you have to do is to modify source code under `app/`.
- Implement a different cloud setup. For example you could change number of Heroku dynos or size and number of Shelly servers, as well as number of workers per dyno or number of pumas per Shelly server. It's only a matter of creating a new subclass in `lib/`, adding it to a `KNOWN_HOSTINGS` list in `lib/options.rb` and reruning the script.
- Write benchmark code for another hosting solution. To do that subclass `Hosting` and implement all the relevant methods, using existing subclasses as a guide.
