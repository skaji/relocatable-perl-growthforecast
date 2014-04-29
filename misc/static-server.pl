#!/usr/bin/env perl
use strict;
use warnings;
use Plack::Runner;
use Plack::App::Directory;
open STDOUT, ">/dev/null";
open STDERR, ">/dev/null";
my $app = Plack::App::Directory->new(root => shift)->to_app;
my $r = Plack::Runner->new;
$r->run($app);
