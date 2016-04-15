Global Names Recognition and Discovery (GNRD)
=============================================

[![Continuous Integration Status][ci_img]][ci]
[![Coverage Status][coverage_img]][coverage]
[![CodePolice][qc_img]][qc]
[![Dependency Status][gems_img]][gems]

GNRD is a [web-application][gnrd]. It finds scientific names in texts, PDF
files, images, web-pages, MS Word and MS Excel documents. [RESTful API][api]
allows to search for scientific names using scripts.

Install
-------

There are quite a few moving parts in the system -- Tesseract for OCR,
Libre Office to read various file formats, Postgresql for data, Redis for
asyncronous execution of commands, NetiNeti and TaxonFinder for name-finding
etc. We recommend to install Docker and Docker Compose to dramatically simplify
the installation process.

You can follow .travis.yml file to see necessary components for the system on a
Debian-based GNU/Linux distribution. You can see docker-compose file to get
insite on how to make a complete Docker-based installation.

Prerequisites
-------------

* Docker >= 1.10
* Docker Composer >= 1.6
* Git

Install for production on one machine
------------------------------------------------

Get source code and swich to production branch

```bash
git clone https://github.com/GlobalNamesArchitecture/gnrd.git
cd gnrd
git checkout production
```

Create directories for database and configuration files

```bash
sudo mkdir -p /opt/gna/data/gnrd/postgresql/data
sudo chown 999:999 -R /opt/gna/data/gnrd/postgresql
sudo mkdir /opt/gna/config/gnrd
sudo cp ./config.json.example /opt/gna/config/gnrd/config.json
sudo cp .config/docker/gnrd.env.example /opt/gna/config/gnrd/gnrd.env
```

Modify config.json and gnrd.env to suit your needs.
Run compose in daemon mode from the project's root directory

```bash
nohup docker-compose up -d
```

Testing
-------

You need Docker >= 1.10 and Docker Composer >= 1.6

Build application's image (needs to be done only if a new gem or new
Ubuntu package are added)

```
docker-compose build

```

Start Docker Compose (in the background)

```
docker-compose up -d

```

Create/update database

```
docker-compose run app rake db:reset
```
should be sufficient

Run all tests

```
docker-compose run app rake
```

Run a specific test

```
# with rake
docker-compose run app rake spec SPEC=spec/lib/some_spec.rb:44

# with rspec
docker-compose run app rspec -r factories spec/lib/some_spec.rb:44
```
Contributing to GNRD
----------------------------

* Check out the latest master to make sure the feature hasn't been implemented
or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested
it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a
future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want
to have your own version, or is otherwise necessary, that is fine, but please
isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Authors: [David Shorthouse][dps], [Dmitry Mozzherin][dimus]

Copyright (c) 2012-2016 Marine Biological Laboratory.
See [LICENSE.txt][license] for further details.

[ci_img]: https://secure.travis-ci.org/GlobalNamesArchitecture/gnrd.svg
[ci]: http://travis-ci.org/GlobalNamesArchitecture/gnrd
[coverage_img]: https://coveralls.io/repos/github/GlobalNamesArchitecture/gnrd/badge.svg?branch=master
[coverage]: https://coveralls.io/github/GlobalNamesArchitecture/gnrd?branch=master
[qc_img]: https://codeclimate.com/github/GlobalNamesArchitecture/gnrd.svg
[qc]: https://codeclimate.com/github/GlobalNamesArchitecture/gnrd
[gems_img]: https://gemnasium.com/GlobalNamesArchitecture/gnrd.svg
[gems]: https://gemnasium.com/GlobalNamesArchitecture/gnrd
[dimus]: https://github.com/dimus
[dps]: https://github.com/dshorthouse
[license]: https://github.com/GlobalNamesArchitecture/gnrd/blob/master/LICENSE.txt
[gnrd]: http://gnrd.globalnames.org
[api]: http://gnrd.globalnames.org/api
