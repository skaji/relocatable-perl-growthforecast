#!/bin/bash

DIR=$( cd $(dirname $0) >/dev/null; pwd )
GITHUB_RELEASE_VERSION=${GITHUB_RELEASE_VERSION:-0.3}

set -e

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# 0
if [ -e /opt/perl ]; then echo Please remove /opt/perl first >&2; exit 1; fi
echo first asking sudo password
sudo true
if [ ! -d $DIR/mac-build ]; then mkdir $DIR/mac-build; fi
cd $DIR/mac-build
find . -maxdepth 1 -name "*.log" -o -name "growthforecast-*.tar.gz" | xargs rm -f
find . -maxdepth 1 ! -path . -type d | xargs rm -rf

# 1
PERL_DIR="perl-darwin-2level"
URL="https://github.com/shoichikaji/relocatable-perl/releases/download/$GITHUB_RELEASE_VERSION/$PERL_DIR.tar.gz"
if [ ! -e "${PERL_DIR}.tar.gz" ]; then
    echo "---> downloading $URL"
    wget -q $URL
else
    echo "---> using pre-downloaded $PERL_DIR.tar.gz"
fi

gtar xzf $PERL_DIR.tar.gz
if [ ! -d /opt ]; then sudo mkdir /opt; fi
sudo mv $PERL_DIR /opt/perl

# 2
/opt/perl/bin/cpanm --no-man-pages --installdeps -nq Alien::RRDtool@0.06
/opt/perl/bin/cpanm --no-man-pages -nq \
    Kossy \
    DBIx::Sunny \
    DBD::SQLite \
    Time::Piece \
    HTTP::Date \
    File::Zglob \
    Log::Minimal \
    List::MoreUtils \
    Starlet \
    HTTP::Parser::XS \
    Proclet \
    Plack::Builder::Conditionals \
    Scope::Container \
    Plack::Middleware::Scope::Container \
    Plack::Middleware::AxsLog \
    Scope::Container::DBI \
    JSON \
    JSON::XS \
    Class::Accessor::Lite \
    URI::Escape

# 3
PREFIX=/opt/perl/local /opt/perl/bin/perl ../rrdtool-deps-install.pl
gcp ../mac.pango.modules /opt/perl/local/etc/pango/pango.modules

# 4
if [ ! -e Alien-RRDtool-0.06.tar.gz ]; then
    wget http://www.cpan.org/authors/id/K/KA/KAZEBURO/Alien-RRDtool-0.06.tar.gz
fi
gtar xzf Alien-RRDtool-0.06.tar.gz
/opt/perl/bin/perl -i -nle \
    'if ($. == 158) {print "my \@dirs = qw(/opt/perl/local/lib);"} else { print }' \
    Alien-RRDtool-0.06/inc/MyBuilder.pm
(
    cd Alien-RRDtool-0.06 &&
    PKGCONFIG=/opt/perl/local/bin/pkg-config \
    PKG_CONFIG_PATH=/opt/perl/local/lib/pkgconfig \
    /opt/perl/bin/cpanm --no-man-pages -nq .
)

# 5
/opt/perl/bin/perl ../mac-rrdtool-tweak.pl

# 6
/opt/perl/bin/cpanm --no-man-pages -nq GrowthForecast

# 7
/opt/perl/bin/perl ../header-growthforecast.pl /opt/perl/bin/growthforecast.pl
/opt/perl/bin/change-shebang -f /opt/perl/bin/*

# 8
NAME=growthforecast-`/opt/perl/bin/perl -MConfig -e 'print $Config{archname}'`
gcp -r /opt/perl $NAME
./$NAME/bin/perl -MRRDs -e1
NUM=`find $NAME/lib -name "*.bundle" | xargs -L1 otool -L | grep /usr/local | wc -l`
if [ $NUM -ne 0 ]; then echo unexpected /usr/local deps; exit 1; fi
NUM=`find $NAME/local/lib -type f -name "*.dylib" | xargs -L1 otool -L | grep /usr/local | wc -l`
if [ $NUM -ne 0 ]; then echo unexpected /usr/local deps; exit 1; fi

# 9
gtar czf ../../$NAME.tar.gz $NAME

