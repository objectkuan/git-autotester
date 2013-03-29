autotester_v2
=============

Running
-------

You should install RVM first (ruby 1.9.3)

* bundle install
* ./frontend.rb
* ./backend.rb
* clockwork ./at_jobs.rb

Hint: if you install rerun (gem install rerun), use `rerun ./frontend.rb' to
auto refresh your website

About Autobuildv2
---------

This Autobuild System is designed to undertake the building and testing 
process automatically. It depends on the following packages:

+ Ruby1.9 with several gems
+ Git
+ Bash

Features
---------
This version includes many new features:

+ frontend & backend separation
+ mailing
+ multi-repo support
+ multi-branch support
+ highly configurable
+ syntax highlight

When someone pushes commits to the Repo, it will trigger the auto-building and auto-testing.
This means a Git fetch action and then the *autobuild.sh* and *autotest.sh* will be run.
You should make sure these two scripts are placed in the root of your target Repo properly.

Note that the backend uses polling to fetch your newest commits.


Configuration
------------
The configuration file is called `config.yaml', you can refer to
config.yaml.template for more details. Please note that you must use *absolute
path* for your repos and results.

Note that you not need to manually clone the repos, the backend will do it for
you at the first run.

Most options are self-explanatory, here are the non-trival ones:

+ ping: the frontend checks the alive signal from backend with a socket. This
  options setup their IP address and port.
+ repos.blacklist: the branches that you do not want to be auto-tested
+ repos.nomail: do NOT send email for this repo's test results

Testing
----------
Run the backend and frontend. 
Then open the web browser, goto 

http://127.0.0.1:PORT_NUMBER/

You should be able to see the start page.


