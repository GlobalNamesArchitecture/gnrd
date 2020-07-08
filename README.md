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
asyncronous execution of commands, `gnfinder` for name-finding
etc. We recommend to install Docker and Docker Compose to dramatically simplify
the installation process.

You can follow .travis.yml file to see necessary components for the system on a
Debian-based GNU/Linux distribution. You can see docker-compose file to get
an insight on how to make a complete Docker-based installation.

Prerequisites
-------------

* Docker >= 1.10
* Docker Compose >= 1.6
* Git

Install in production environment on one machine
------------------------------------------------

NOTE: This install is not safe, and is given to test installation by new users. You need to create real passwords
and change settings in `.env` file accordingly, also you need to remove `POSTGRES_HOST_AUTH_METHOD=trust` environment variable from `.env` file.

Here we will assume installation is done by a user `john` with a group `john`

Add user `john` to `docker` group in `/etc/group` and relog.
This will give the user privileges to operate docker.

Get source code and swich to production branch

```bash
git clone https://github.com/GlobalNamesArchitecture/gnrd.git
cd gnrd git checkout production ```

Create directory for the database

```bash
sudo mkdir -p /opt/gna/data/gnrd/postgresql/data
sudo chown john:john -R /opt/gna/data/gnrd/postgresql
```

Optionally pull gnames/gnrd from dockerhub to save time on the gnrd docker
image building step

```bash
docker pull gnames/gnrd
```

Run docker compose from the project's root directory

```bash
docker-compose up
# or in daemon mode:
nohup docker-compose up -d
```

Initialize database:
```bash
docker-compose run app rake db:reset
```

Now you should have a working version of GNRD on http://0.0.0.0:9292 and
the following command should work as expected

```bash
curl -L http://0.0.0.0:9292/name_finder.json?url=http://en.wikipedia.org/wiki/Araneae
```

The response should include a URL that will contain the found names.

You can change the placement of default directories, and ports by modifying
[docker-compose]
file

After you made it working login to PostgreSQL, set an account and password and change `.env` file accordingly. Remove the `POSTGRES_HOST_AUTH_METHOD=trust` environment variable from `.env` file.

Development and Testing
-----------------------

You need Docker >= 1.10 and Docker Compose >= 1.6

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

Authors: [Dmitry Mozzherin][dimus], [David Shorthouse][dps]

Copyright © 2012-2019 Marine Biological Laboratory.
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
[docker-compose]: https://github.com/GlobalNamesArchitecture/gnrd/blob/production/docker-compose.yml
