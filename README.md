Global Names Recognition and Discovery (GNRD)
=============================================

[![Continuous Integration Status][ci_img]][ci]
[![Coverage Status][coverage_img]][coverage]
[![CodePolice][qc_img]][qc]
[![Dependency Status][gems_img]][gems]

GNRD finds scientific names in texts, pdf files, images, web-pages

Testing
-------

You need Docker >= 1.10 and Docker Composer >= 1.6

1. Build application's image (needs to be done only if a new gem or new
ubuntu package are added)

```
docker-compose build
```
2. Start Docker Compose (in the background)

```
docker-compose up -d
```

3. Run tests

```
docker-compose run app rake
```

or to run a test on line 44

```
docker-compose run app rspec spec/lib/some_spec.rb:44
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
