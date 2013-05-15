Global Names Recognition and Discovery (GNRD)
=============================================

[![Continuous Integration Status][1]][2]

Sinatra application to find scientific names in web pages and documents.

See http://gnrd.globalnames.org/

Running Specs
-------------

To be able to run specs, both TaxonFinder and NetiNeti need to be run locally.
Get these at http://code.google.com/p/taxon-finder/ and 
https://github.com/mbl-cli/NetiNeti, respectively.

For testing API calls, a resque worker needs to be running:

    QUEUE=name_finder rake resque:work

Several additional packages need to be installed on the operating system to 
satisfy docsplit dependencies. See http://documentcloud.github.io/docsplit/ 
for details.

You can also check continuous integration server configuration file .travis.yml
for more information on setting up testing environment.

In production:
--------------

If multiple instances of TaxonFinder and NetiNeti are desirable, these can be 
made available via HAProxy. See config.yml.example for configuration of hosts 
and ports. Multiple workers can be used by specifying COUNT.

    RACK_ENV=production COUNT=5 QUEUE=name_finder rake resque:workers


[1]: https://secure.travis-ci.org/GlobalNamesArchitecture/gnrd.png
[2]: http://travis-ci.org/GlobalNamesArchitecture/gnrd
