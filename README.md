# Relocatable Perl with GrowthForecast

This repository is just an attempt to show
how latest, pre-compiled, relocatable Perl is useful!

You can download *latest*, *pre-compiled*, *relocatable* Perl with GrowthForecast from
[release page](https://github.com/shoichikaji/relocatable-perl-growthforecast/releases).

Once you fetch a tarball, just extract it to your favorite directory
and type

    > perl/bin/growthforecast.pl

Access 5125 port:

    > curl http://localhost:5125

I've confirmed that the pre-compiled perl worked in 64bit centos6.4 and ubuntu14.04.

## how to build yourself

It's pretty easy (I hope so). Install docker and type:

    > docker build -t you/perl git://github.com/shoichikaji/relocatable-perl-growthforecast.git
    > docker run -d you/perl
    > docker cp CONTAINER_ID:/opt/perl.tar.gz .

## pull docker image

    > docker pull skaji/relocatable-perl-growthforecas

See https://registry.hub.docker.com/u/skaji/relocatable-perl-growthforecas

