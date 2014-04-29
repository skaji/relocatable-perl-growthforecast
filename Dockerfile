FROM centos:6.4
MAINTAINER Shoichi Kaji <skaji@cpan.org>

RUN yum install -y gcc g++ xz gcc-c++ make chrpath perl

RUN mkdir /root/build /root/perl
WORKDIR /root/build

ADD misc/rrdtool-deps-install.pl /root/build/rrdtool-deps-install.pl
RUN PREFIX=/root/perl/local /usr/bin/perl rrdtool-deps-install.pl
ADD misc/pango.modules /root/perl/local/etc/pango/pango.modules

RUN wget -q http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz
RUN tar xzf perl-5.18.2.tar.gz && cd perl-5.18.2 && \
    ./Configure -Dprefix=/root/perl -Duserelocatableinc -Dlibpth='/usr/local/lib /lib64 /lib/x86_64-linux-gnu /lib /usr/lib64 /usr/lib/x86_64-linux-gnu /usr/lib /usr/local/lib64' -des &>> /root/build/perl-build.log && \
    make install &>> /root/build/perl-build.log

RUN wget -q --no-check-certificate -O - http://cpanmin.us | \
    /root/perl/bin/perl - App::cpanminus

RUN /root/perl/bin/cpanm --installdeps -n -q Alien::RRDtool

ADD misc/Alien-RRDtool-0.05-patch /root/build/Alien-RRDtool-0.05-patch
RUN wget -q http://search.cpan.org/CPAN/authors/id/G/GF/GFUJI/Alien-RRDtool-0.05.tar.gz
RUN tar xzf Alien-RRDtool-0.05.tar.gz && cd Alien-RRDtool-0.05 && \
    patch -p0 < ../Alien-RRDtool-0.05-patch && \
    PKGCONFIG=/root/perl/local/bin/pkg-config \
    PKG_CONFIG_PATH=/root/perl/local/lib/pkgconfig \
    /root/perl/bin/cpanm -n .

RUN chrpath -r \$ORIGIN/../../../../../../local/lib \
    /root/perl/lib/site_perl/5.18.2/x86_64-linux/auto/RRDs/RRDs.so
RUN /root/perl/bin/perl -MRRDs -e0

RUN /root/perl/bin/cpanm -n --installdeps -q GrowthForecast
RUN /root/perl/bin/cpanm -n GrowthForecast

# I don't know why: sometimes missing dist share files
RUN if [ `find /root/perl/lib/site_perl/5.18.2/auto/share/dist/GrowthForecast -type f | wc -l` -eq 20 ]; then \
    echo GrowthForecast share files exist; \
else \
    find /root/perl/lib/site_perl/5.18.2/auto/share/dist/GrowthForecast -type f >&2; perl -e 'die "some GrowthForecast files missing!\n"'; \
fi

ADD misc/header-growthforecast.pl /root/build/header-growthforecast.pl
RUN /root/perl/bin/perl /root/build/header-growthforecast.pl /root/perl/bin/growthforecast.pl
ADD misc/change-shebang.pl /root/build/change-shebang.pl
RUN /root/perl/bin/perl /root/build/change-shebang.pl /root/perl/bin/*

RUN cd /root && tar czf perl.tar.gz perl

ADD misc/static-server.pl /root/static-server.pl
EXPOSE 5000
CMD ["/root/perl/bin/perl", "/root/static-server.pl", "/root"]