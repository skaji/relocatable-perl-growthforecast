# Relocatable Perl with GrowthForecast

This repository is just an attempt to show
how latest, pre-compiled, relocatable Perl is useful!

You can download *latest*, *pre-compiled*, *relocatable* Perl with GrowthForecast from
[release page](https://github.com/shoichikaji/relocatable-perl-growthforecast/releases).

## install

Just fetch a tarball, and extract it to your favorite directory:

    > wget https://github.com/shoichikaji/relocatable-perl-growthforecast/releases/download/0.10/growthforecast-0.83-x86_64-linux.tar.gz
    > tar xzf growthforecast-0.83-x86_64-linux.tar.gz
    > mv growthforecast-0.83-x86_64-linux ~/my-favorite-name

    > ~/my-favorite-name/bin/growthforecast.pl

Then access 5125 port:

    > curl http://localhost:5125

I've confirmed that the pre-compiled perl worked on:

* 64bit centos 6.4 and ubuntu 12.04, 14.04 (growthforecast-0.83-x86_64-linux.tar.gz)
* Mac OS X 10.9.4 (growthforecast-0.83-darwin-2level.tar.gz)

## how to build yourself

It's pretty easy (I hope so). Install docker and type:

    > docker build -t you/perl git://github.com/shoichikaji/relocatable-perl-growthforecast.git
    > docker run -d you/perl
    > docker cp CONTAINER_ID:/opt/perl.tar.gz .

## pull docker image

    > docker pull skaji/relocatable-perl-growthforecas

See https://registry.hub.docker.com/u/skaji/relocatable-perl-growthforecas

