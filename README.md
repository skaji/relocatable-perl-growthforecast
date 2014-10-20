# Relocatable Perl with GrowthForecast

[![Build Status](https://api.travis-ci.org/shoichikaji/relocatable-perl-growthforecast.svg)](https://travis-ci.org/shoichikaji/relocatable-perl-growthforecast)

This repository is just an attempt to show
how latest, pre-compiled, relocatable Perl is useful.

You can download *latest*, *pre-compiled*, *relocatable* Perl with GrowthForecast from
[release page](https://github.com/shoichikaji/relocatable-perl-growthforecast/releases).

## how to install

Just fetch a tarball (darwin-2level or x86_64-linux), and extract it to your favorite directory:

    # MacOS X example
    > wget https://github.com/shoichikaji/relocatable-perl-growthforecast/releases/download/0.32/growthforecast-darwin-2level.tar.gz
    > tar xzf growthforecast-darwin-2level.tar.gz
    > mv growthforecast-darwin-2level ~/my-favorite-name

    > ~/my-favorite-name/bin/growthforecast.pl

Then GrowthForecast will be accepting connections at 5125 port:

    > curl http://localhost:5125

I've confirmed that the pre-compiled perl worked on:

* 64bit CentOS 6.5 and Ubuntu 12.04, 14.04 (growthforecast-x86_64-linux.tar.gz)
* Mac OS X 10.9.5 (growthforecast-darwin-2level.tar.gz)

## how to build yourself

See [Dockerfile](https://github.com/shoichikaji/relocatable-perl-growthforecast/blob/master/Dockerfile)
and [mac.sh](https://github.com/shoichikaji/relocatable-perl-growthforecast/blob/master/misc/mac.sh).

## docker image

https://registry.hub.docker.com/u/skaji/relocatable-perl-growthforecas

