#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';
use utf8;
BEGIN {
    package pushd;
    use Cwd ();
    sub pushd {
        my ($dir, $sub) = @_;
        my $self = bless { dir => Cwd::getcwd() }, __PACKAGE__;
        chdir $dir or die;
        $sub->();
    }
    sub DESTROY { chdir shift->{dir} or die; }
    *main::pushd = *pushd;
}


sub run { print "-> @_\n"; !system @_ or die "=> FAIL @_\n"; }
sub install {
    my $url   = shift;
    my $extra = shift || "";
    my ($archive) = $url =~ m{/([^/]+)$};
    my ($dir, $type) = $archive =~ m{(.+)\.(tar\.gz|tar\.bz2|tar\.xz)$};

    my $tar_option = $type eq 'tar.gz'  ? 'xzf'
                   : $type eq 'tar.bz2' ? 'xjf'
                   :                      'xJf';

    print "\e[1;37m", "-> installing $dir", "\e[m", "\n" if -t STDIN;
    if (-f $archive) {
        print "-> using pre-download $archive\n";
    } else {
        run "wget", "-q", $url;
    }

    run "rm -rf $dir" if -d $dir;
    run "tar", $tar_option, $archive;
    pushd $dir => sub {
        my $log = sprintf "../%s.%d.log", $dir, time;
        my @configure = ("--prefix=$ENV{PREFIX}", $extra);
        if ($dir !~ /zlib/) {
            push @configure, "--enable-shared", "--enable-static";
        }
        eval { run "./configure @configure >> $log 2>&1"; };
        if ($@) { run "cat $log"; exit 255 }
        eval { run "make -j 4 >> $log 2>&1"; };
        if ($@) { run "cat $log"; exit 255 }
        run "make install >> $log 2>&1";
    };
    run "rm -rf $dir";
}

my $prefix = $ENV{PREFIX} or die "should set environment variable PREFIX";
$ENV{CFLAGS} = "-O3 -fPIC";
$ENV{LDFLAGS} = "-L$prefix/lib -Wl,-rpath,$prefix/lib";
$ENV{CPPFLAGS} = "-I$prefix/include";
$ENV{PATH} = "$prefix/bin:$ENV{PATH}";

install "http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz",
     "--with-internal-glib";

$ENV{PKGCONFIG} = "$prefix/bin/pkg-config";
$ENV{PKG_CONFIG} = $ENV{PKGCONFIG};
$ENV{PKG_CONFIG_PATH} = "$prefix/lib/pkgconfig";

install "http://zlib.net/zlib-1.2.8.tar.gz";
install "http://prdownloads.sourceforge.net/libpng/libpng-1.6.10.tar.gz";
install "http://download.savannah.gnu.org/releases/freetype/freetype-2.5.3.tar.gz";
install "ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz",
    "--without-python";
install "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz";
install "http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.1.tar.gz";
install "http://cairographics.org/releases/pixman-0.32.4.tar.gz";
install "http://cairographics.org/releases/cairo-1.12.16.tar.xz",
     "--enable-xlib=no --enable-xlib-render=no --enable-win32=no";
install "ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz"; # 3.0.13 has location bug
install "http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.3.2.tar.gz";
install "http://ftp.gnome.org/pub/gnome/sources/glib/2.40/glib-2.40.0.tar.xz";
install "http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.27.tar.bz2";
install "http://ftp.gnome.org/pub/GNOME/sources/pango/1.36/pango-1.36.3.tar.xz"; # need perl for installation?
