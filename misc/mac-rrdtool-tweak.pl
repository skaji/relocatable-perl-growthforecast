#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use File::Basename 'basename';
sub capture { my @out = `@_`; die "===> FAIL @_\n" if $? != 0; chomp @out; @out }
sub run { print "---> @_\n"; !system @_ or die "===> FAIL @_\n" }

if (@ARGV && $ARGV[0] =~ /^(-h|--help)$/) {
    print <<'...';
Usage:
    > mac-rrdtool-tweak.pl [PERL_VERSION]
...
    exit;
}

my $perl_version = shift || "5.20.0";
my $lib_dir = "/opt/perl/local/lib";
my $rrds_bundle = "/opt/perl/lib/site_perl/$perl_version/darwin-2level/auto/RRDs/RRDs.bundle";
-e $lib_dir or die "missing $lib_dir\n";
-e $rrds_bundle or die "missing $rrds_bundle\n";

for my $file (grep !-l, glob "$lib_dir/*.dylib") {
    run "chmod 755 $file";
    for my $line (capture "otool -L $file") {
        $line =~ s/^\s+//;
        my ($link) = split /\s+/, $line;
        if ($link =~ m/^$lib_dir/ && $link ne $file) {
            my $name = basename $link;
            run "install_name_tool -change $link '\@loader_path/$name' $file";
        }
    }
}

run "chmod 755 $rrds_bundle";
for my $line (capture "otool -L $rrds_bundle") {
    $line =~ s/^\s+//;
    my ($link) = split /\s+/, $line;
    if ($link =~ m/^$lib_dir/ && $link ne $rrds_bundle) {
        my $name = basename $link;
        my $relative = '@loader_path/../../../../../../local/lib';
        run "install_name_tool -change $link '$relative/$name' $rrds_bundle";
    }
}

