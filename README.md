Surprise cron
=============

Surprise !

The cron that runs at a random time. Not entirely random of course, you specify how often you want the job to run and the interval (ie: 3x a week) and it will execute the job at an arbitrary time within that period.  
This was born out of a very specific need, but I decided to share it anyway.

Usage
======

	Usage: surprise [command] [options]

	Command is one of the following:
	    run   - Run the daemon without forking (default)
	    start - Run the daemon
	    stop  - Stop the running daemon

	Options can be:
	    -n, --number NUMBER              how many times it should run
	    -t, --time INTERVAL              the unit time for the frequency, in seconds
	    -h, --help                       display this message
	    -v, --version                    show version  

Example:  

	./bin/surprise start -n 4 -t 60  (will run at 4 random times in a minute)
	./bin/surprise stop

Structure
=========

Here's the important things you need to know about. The Job class has a 'work' method you need to implement and the scheduler will automatically invoke it when it's time.  
./bin/surprise is the script you'll typically use for job control

	.
	├── bin
	│   └── surprise
	├── config
	│   ├── pre-daemonize
	│   │   └── job.rb
	├── Gemfile
	└── log

Installation
============

The sample job that comes with the default install has a few system dependencies. Before you bundle install, make sure you have the following

    libcurl
    libxml
    libxslt

You might need to specify:  

    bundle config build.nokogiri --use-system-libraries  


Don't forget to set the email sender and recipients !
