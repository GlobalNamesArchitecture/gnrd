Global Names Recognition and Discovery (GNRD)
=============================================

[![Continuous Integration Status][ci_img]][ci]
[![Coverage Status][coverage_img]][coverage]
[![CodePolice][qc_img]][qc]
[![Dependency Status][gems_img]][gems]

GNRD finds scientific names in texts, pdf files, images, web-pages

Install
-------

There are quite a few moving parts in the system -- Tesseract or OCR,
Libre Office to read various file formats, Postgresql for data, Redis for
asyncronous execution of commands, NetiNeti and TaxonFinder for name-finding
etc. We recommend to install Docker to simplify setup of the system
dramatically.

You can follow .travis.yml file to see necessary components for the system on a
Debian-based GNU/Linux distribution. You can see docker-compose file to get
inside how to make a complete Docker-based installation.

Testing
-------

You need Docker >= 1.10 and Docker Composer >= 1.6

* Build application's image (needs to be done only if a new gem or new
   ubuntu package are added)

```
docker-compose build

```

* Start Docker Compose (in the background)

```
docker-compose up -d

```

* Create/update database

```
# run this only if you need to remove old version of db
doker-compose run app rake db:drop

docker-compose run app rake db:create

docker-compose run app rake db:migrate
docker-compose run app env RACK_ENV=test rake db:migrate
```

After database and migrations are created, `schema.rb`
will be created as well. Next time after restarting
containers just running

```
docker-compose run app rake db:setup
```
is sufficient

* Run tests

For all tests run

```
docker-compose run app rake
```

or to run a specific test

```
docker-compose run app rspec -r factories spec/lib/some_spec.rb:44
```

[ci_img]: https://secure.travis-ci.org/GlobalNamesArchitecture/gnrd.svg
[ci]: http://travis-ci.org/GlobalNamesArchitecture/gnrd
[coverage_img]: https://coveralls.io/repos/github/GlobalNamesArchitecture/gnrd/badge.svg?branch=master
[coverage]: https://coveralls.io/github/GlobalNamesArchitecture/gnrd?branch=master
[qc_img]: https://codeclimate.com/github/GlobalNamesArchitecture/gnrd.svg
[qc]: https://codeclimate.com/github/GlobalNamesArchitecture/gnrd
[gems_img]: https://gemnasium.com/GlobalNamesArchitecture/gnrd.svg
[gems]: https://gemnasium.com/GlobalNamesArchitecture/gnrd
[5]: http://docs.vagrantup.com/v2/getting-started/index.html
[6]: http://docs.vagrantup.com/v2/installation/
[7]: https://www.virtualbox.org/wiki/Downloads
