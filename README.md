# Relocatable Perl with GrowthForecast

This repository is just an attempt that shows
how latest, pre-compiled, relocatable Perl is useful!

You can download *lastest*, *pre-compiled*, *relocatable* Perl with GrowthForecast from
[release page](https://github.com/shoichikaji/relocatable-perl-growthforecast/releases).

Once you fetch a tarball, just extract it to your favorite directory
and type

    > bin/growthforecast.pl

Access 5125 port:

    > curl http://localhost:5125

I've confirmed that the pre-compiled perl worked in 64bit centos6.4 and ubuntu14.04.


## how to build yourself

It's pretty easy (I hope so). Install docker and type:

    > docker build -t you/perl git://github.com/shoichikaji/relocatable-perl-growthforecast.git
    # wait, wait, wait, ..
    > docker run -d -p 5000:5000 you/perl
    > wget http://localhost:5000/perl.tar.gz

