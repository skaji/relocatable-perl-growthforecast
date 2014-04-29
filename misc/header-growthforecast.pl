#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp 'tempfile';
use File::Basename 'dirname';

my $gf = shift or die;
my $mode = (stat $gf)[2];
my $content = do { open my $fh, "<", $gf or die; local $/; <$fh> };

my ($fh, $tempfile) = tempfile UNLINK => 0, DIR => dirname($gf);
chmod $mode, $tempfile;
print {$fh} <<'...';
#!/bin/sh
exec "$(dirname "$0")"/perl -x -- "$0" "$@"
#!perl
use FindBin;
$ENV{FONTCONFIG_FILE} = "$FindBin::Bin/../local/etc/fonts/fonts.conf";
$ENV{PANGO_LIBDIR} = "$FindBin::Bin/../local/lib";
$ENV{PANGO_SYSCONFDIR} = "$FindBin::Bin/../local/etc";
...
print {$fh} $content;
close $fh;

rename $tempfile, $gf or die "rename: $!";
