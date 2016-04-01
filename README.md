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

Prerequisites
-------------

* Docker >= 1.10
* Docker Composer >= 1.6
* Git

Production system using docker-compose
--------------------------------------

Get source code and swich to production branch

```bash
git clone https://github.com/GlobalNamesArchitecture/gnrd.git
cd gnrd
git co production
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
Run compose in daemon mode

```bash
nohup docker-compose up -d
```

Testing
-------

You need Docker >= 1.10 and Docker Composer >= 1.6

* Build application's image (needs to be done only if a new gem or new
   Ubuntu package are added)

```
docker-compose build

```

* Start Docker Compose (in the background)

```
docker-compose up -d

```

* Create/update database

```
docker-compose run app rake db:reset
```
should be sufficient

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
