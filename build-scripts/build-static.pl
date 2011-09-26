#!/usr/bin/perl
#
# Script to build a static binary of redstore, including its dependancies
#

use File::Basename;
use Cwd;
use strict;
use warnings;

my $TOP_DIR = Cwd::realpath(dirname(__FILE__).'/..');
my $BUILD_DIR = "$TOP_DIR/build";
my $ROOT_DIR = "$TOP_DIR/root";
my $DEFAULT_CONFIGURE_ARGS = "--enable-static --disable-shared --prefix=$ROOT_DIR ".
                             "--disable-gtk-doc --disable-dependency-tracking ".
                             "--disable-rebuilds";

my $packages = [
    {
        'url' => 'http://pkgconfig.freedesktop.org/releases/pkg-config-0.25.tar.gz',
        'config' => "./configure $DEFAULT_CONFIGURE_ARGS --with-pc-path=${ROOT_DIR}/lib/pkgconfig",
        'checkfor' => 'bin/pkg-config',
    },
    {
        'dirname' => 'check-0.9.8',
        'url' => 'http://www.aelius.com/njh/redstore/check-20100409.tar.gz',
        'checkfor' => 'bin/checkmk',
    },
    {
        'url' => 'http://kent.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz',
        'checkfor' => 'lib/libmhash.a',
    },
    {
        'url' => 'http://curl.haxx.se/download/curl-7.21.7.tar.gz',
        'config' => "./configure $DEFAULT_CONFIGURE_ARGS ".
                    "--disable-ssh --disable-ldap --disable-ldaps --disable-rtsp ".
                    "--without-librtmp --disable-dict --disable-telnet --disable-pop3 ".
                    "--disable-imap --disable-smtp --disable-manual --without-libssh2",
        'checkfor' => 'lib/pkgconfig/libcurl.pc',
    },
    {
        'url' => 'http://kent.dl.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.bz2',
        'config' => "./configure $DEFAULT_CONFIGURE_ARGS ".
                    "--enable-utf8 --enable-unicode-properties",
        'checkfor' => 'lib/pkgconfig/libpcre.pc'
    },
# FIXME: can't build a universal binary of GMP
#     {
#         'url' => 'ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2',
#         'config' => "./configure $DEFAULT_CONFIGURE_ARGS ABI=32",
#         'checkfor' => 'lib/libgmp.la',
#     },
    {
        # NOTE: libxml2-2.7.8 doesn't seem to work with Mac OS 10.6 zlib
        'url' => 'http://xmlsoft.org/sources/libxml2-2.7.6.tar.gz',
        'checkfor' => 'lib/pkgconfig/libxml-2.0.pc',
    },
    {
        'url' => 'http://xmlsoft.org/sources/libxslt-1.1.26.tar.gz',
        'checkfor' => 'lib/pkgconfig/libxslt.pc',
    },
    {
        'url' => 'http://github.com/lloyd/yajl/tarball/1.0.12',
        'dirname' => 'lloyd-yajl-17b1790',
        'tarname' => 'yajl-1.0.12.tar.gz',
        'config' => "mkdir build && cd build && cmake ..",
        'make' => "cd build && make yajl_s",
        'install' => "cd build/yajl-1.0.12 && ".
                     "cp -Rfv include/yajl ${ROOT_DIR}/include/ && ".
                     "cp -fv lib/libyajl_s.a ${ROOT_DIR}/lib/libyajl.a",
        'checkfor' => 'lib/libyajl.a',
    },
    {
        'dirname' => 'sqlite-3.7.3',
        'url' => 'http://www.sqlite.org/sqlite-amalgamation-3.7.3.tar.gz',
        'checkfor' => 'lib/pkgconfig/sqlite3.pc',
    },
    {
        'url' => 'http://download.oracle.com/berkeley-db/db-4.8.26.tar.gz',
        'config' => "cd build_unix && ../dist/configure $DEFAULT_CONFIGURE_ARGS --disable-java",
        'make' => 'cd build_unix && make',
        'install' => 'cd build_unix && make install',
        'checkfor' => 'lib/libdb.a',
    },
#     {
#         'url' => 'http://www.iodbc.org/downloads/iODBC/libiodbc-3.52.7.tar.gz',
#         'config' => "./configure $DEFAULT_CONFIGURE_ARGS --disable-gui --disable-gtktest",
#         'checkfor' => 'lib/pkgconfig/libiodbc.pc',
#     },
#     {
#         'url' => 'http://ftp.heanet.ie/mirrors/www.mysql.com/Downloads/MySQL-5.1/mysql-5.1.57.tar.gz',
#         'config' => "./configure $DEFAULT_CONFIGURE_ARGS --without-server --without-docs --without-man",
#         'checkfor' => 'lib/mysql/libmysqlclient.la',
#     },
#     {
#         'url' => 'http://ftp2.uk.postgresql.org/sites/ftp.postgresql.org/source/v9.0.3/postgresql-9.0.3.tar.gz',
#         'config' => "./configure --prefix=${ROOT_DIR}",
#         'make' => 'make -C src/bin/pg_config && '.
#                   'make -C src/interfaces/libpq all-static-lib',
#         'install' => 'make -C src/bin/pg_config install && '.
#                      "cp -fv src/include/postgres_ext.h ${ROOT_DIR}/include/ && ".
#                      "cp -fv src/interfaces/libpq/libpq-fe.h ${ROOT_DIR}/include/ && ".
#                      'make -C src/interfaces/libpq install-lib-static',
#         'checkfor' => 'lib/libpq.a',
#     },
    {
        'url' => 'http://download.librdf.org/source/raptor2-2.0.4.tar.gz',
        'config' => "./configure $DEFAULT_CONFIGURE_ARGS --with-yajl=${ROOT_DIR}",
        'checkfor' => 'lib/pkgconfig/raptor2.pc',
    },
    {
        'url' => 'http://download.librdf.org/source/rasqal-0.9.27.tar.gz',
        'config' => "./configure $DEFAULT_CONFIGURE_ARGS --enable-raptor2 --enable-query-languages=all",
        'checkfor' => 'lib/pkgconfig/rasqal.pc',
    },
    {
        'url' => 'http://download.librdf.org/source/redland-1.0.14.tar.gz',
        'config' => "./configure $DEFAULT_CONFIGURE_ARGS --enable-raptor2 --disable-modular ".
                    "--with-bdb=${ROOT_DIR} --with-threestore=no --with-mysql=no --with-sqlite=3 ".
                    "--with-postgresql=no --with-virtuoso=no",
        'checkfor' => 'lib/pkgconfig/redland.pc',
    },
    {
        'name' => 'redstore',
        'dirpath' => $TOP_DIR,
        'test' => 'make check',
        'checkfor' => 'bin/redstore',
        'alwaysbuild' => 1,
    },
];

# Reset environment variables
$ENV{'CFLAGS'} = "-O2 -I${ROOT_DIR}/include";
$ENV{'CPPFLAGS'} = "-I${ROOT_DIR}/include";
$ENV{'ASFLAGS'} = "-I${ROOT_DIR}/include";
$ENV{'LDFLAGS'} = "-L${ROOT_DIR}/lib";
$ENV{'INFOPATH'} = "${ROOT_DIR}/share/info";
$ENV{'MANPATH'} = "${ROOT_DIR}/share/man";
$ENV{'M4PATH'} = "${ROOT_DIR}/share/aclocal";
$ENV{'PATH'} = "${ROOT_DIR}/bin:/usr/bin:/bin";
$ENV{'PKG_CONFIG_PATH'} = "${ROOT_DIR}/lib/pkgconfig";
$ENV{'CLASSPATH'} = '';

# Check tools required are available
my @TOOLS_REQUIRED = ('cmake', 'curl', 'ed', 'make', 'patch', 'tar');
foreach my $cmd (@TOOLS_REQUIRED) {
  system("which $cmd > /dev/null") && die "Error: $cmd is not available on this system.";
}

# Add extra CFLAGS if this is Mac OS X
if (`uname` =~ /^Darwin/) {
    die "Mac OS X Developer Tools are not available." unless (-e '/Developer/');

    # Build Universal Binrary for both PPC and i386
    my $SDK_VER = '10.4';
    my $SDK = '/Developer/SDKs/MacOSX10.4u.sdk';
    my $ARCHES = '-arch i386 -arch ppc';
    my $MINVER = "-mmacosx-version-min=$SDK_VER";
    die "Mac OS X SDK is not available." unless (-e $SDK);

    $ENV{'CFLAGS'} .= " -isysroot $SDK $ARCHES $MINVER";
    $ENV{'LDFLAGS'} .= " -Wl,-syslibroot,$SDK $ARCHES $MINVER";
    $ENV{'CFLAGS'} .= " -force_cpusubtype_ALL";
    $ENV{'LDFLAGS'} .= " -Wl,-headerpad_max_install_names";
    $ENV{'MACOSX_DEPLOYMENT_TARGET'} = $SDK_VER;
    $ENV{'CMAKE_OSX_ARCHITECTURES'} = 'ppc;i386';

    my $GCC_VER = '4.0';
    $ENV{'CC'} = "/Developer/usr/bin/gcc-$GCC_VER";
    $ENV{"CPP"} = "/Developer/usr/bin/cpp-$GCC_VER";
    $ENV{"CXX"} = "/Developer/usr/bin/g++-$GCC_VER";
    die "gcc version $GCC_VER is not available." unless (-e $ENV{'CC'});

    # Not sure why these are required
    $ENV{'CFLAGS'} .= " -I$SDK/usr/include";
    $ENV{'LDFLAGS'} .= " -L$SDK/usr/lib";
}

$ENV{'CXXFLAGS'} = $ENV{'CFLAGS'};

print "Build directory: $BUILD_DIR\n";
mkdir($BUILD_DIR);

print "Root directory: $ROOT_DIR\n";
mkdir($ROOT_DIR);
mkdir($ROOT_DIR.'/bin');
mkdir($ROOT_DIR.'/include');
mkdir($ROOT_DIR.'/lib');
mkdir($ROOT_DIR.'/share');

gtkdoc_hack($ROOT_DIR);


foreach my $pkg (@$packages) {
    if (defined $pkg->{'url'} and !defined $pkg->{'tarname'}) {
        ($pkg->{'tarname'}) = ($pkg->{'url'} =~ /([^\/]+)$/);
    }
    if (defined $pkg->{'tarname'} and !defined $pkg->{'tarpath'}) {
        $pkg->{'tarpath'} = $BUILD_DIR.'/'.$pkg->{'tarname'};
    }
    if (defined $pkg->{'tarname'} and !defined $pkg->{'dirname'}) {
        ($pkg->{'dirname'}) = ($pkg->{'tarname'} =~ /^([\w\.\-]+[\d\.\-]+\d)/);
        $pkg->{'dirname'} =~ s/_/\-/g;
    }
    if (defined $pkg->{'dirname'} and !defined $pkg->{'dirpath'}) {
        $pkg->{'dirpath'} = $BUILD_DIR.'/'.$pkg->{'dirname'};
    }
    if (defined $pkg->{'dirname'} and !defined $pkg->{'name'}) {
        $pkg->{'name'} = $pkg->{'dirname'};
    }

    unless ($pkg->{'alwaysbuild'} or defined $pkg->{'checkfor'}) {
        die "Don't know how to check if ".$pkg->{'name'}." is already built.";
    }

    if ($pkg->{'alwaysbuild'} or !-e $ROOT_DIR.'/'.$pkg->{'checkfor'}) {
        download_package($pkg) if (defined $pkg->{'url'});
        extract_package($pkg) if (defined $pkg->{'tarpath'});
        clean_package($pkg);
        patch_package($pkg);
        config_package($pkg);
        make_package($pkg);
        test_package($pkg);
        install_package($pkg);

        if (defined $pkg->{'checkfor'} && !-e $ROOT_DIR.'/'.$pkg->{'checkfor'}) {
            die "Installing $pkg->{'name'} failed.";
        }
    }
}

print "Finished compiling:\n";
my @package_names = sort(map {$_->{'name'}} @$packages);
foreach my $name (@package_names) {
    print " * $name\n";
}

if (`uname` =~ /^Darwin/) {
    print "Copying static binary into Xcode project:\n  ";
    safe_system('mkdir', 'macosx/bin') unless (-e 'macosx/bin');
    safe_system('cp', 'src/redstore', 'macosx/bin/redstore-cli');

    # Write out Credits document
    print "Writing Credits.html into Xcode project.\n";
    open(CREDITS, ">macosx/Credits.html") or die "Failed to write to credits file: $!";
    print CREDITS "<!DOCTYPE html>\n";
    print CREDITS "<html>\n";
    print CREDITS "<head><title>RedStore Credits</title></head>\n";
    print CREDITS "<body style='font-family: Tahoma, sans-serif; font-size: 8pt'>\n";
    print CREDITS "  <p>This version of RedStore uses following libraries:</p>\n";
    print CREDITS "  <ul>\n";
    foreach my $name (@package_names) {
        next if ($name eq 'redstore');
        print CREDITS "    <li>$name</li>\n";
    }
    print CREDITS "  </ul>\n";
    print CREDITS "</body>\n";
    print CREDITS "</html>\n";
    close(CREDITS);
}

sub extract_package {
    my ($pkg) = @_;
    if (-e $pkg->{'dirpath'}) {
        print "Deleting old: $pkg->{'dirpath'}\n";
        safe_system('rm', '-Rf', $pkg->{'dirpath'});
    }

    safe_chdir();
    print "Extracting: $pkg->{'tarname'} into $pkg->{'dirpath'}\n";
    if ($pkg->{'tarname'} =~ /bz2$/) {
        safe_system('tar', '-jxf', $pkg->{'tarpath'});
    } elsif ($pkg->{'tarname'} =~ /gz$/) {
        safe_system('tar', '-zxf', $pkg->{'tarpath'});
    } else {
        die "Don't know how to decomress archive.";
    }
}

sub download_package {
    my ($pkg) = @_;

    unless (-e $pkg->{'tarpath'}) {
        safe_chdir();
        print "Downloading: ".$pkg->{'tarname'}."\n";
        safe_system('curl', '-L', '-k', '-o', $pkg->{'tarpath'}, $pkg->{'url'});
    }
}

sub clean_package {
    my ($pkg) = @_;

    safe_chdir($pkg->{'dirpath'});
    print "Cleaning: ".$pkg->{'name'}."\n";
    if ($pkg->{'clean'}) {
        system($pkg->{'clean'});
    } else {
        # this is allowed to fail
        system('make', 'clean') if (-e 'Makefile');
    }
}

sub patch_package {
    my ($pkg) = @_;
    if ($pkg->{'patch'}) {
        safe_chdir($pkg->{'dirpath'});
        my $patchfile = $TOP_DIR.'/'.$pkg->{'patch'};
        safe_system("patch -p0 < $patchfile");
    }
}

sub config_package {
    my ($pkg) = @_;

    safe_chdir($pkg->{'dirpath'});
    print "Configuring: ".$pkg->{'name'}."\n";
    if ($pkg->{'config'}) {
        safe_system($pkg->{'config'});
    } else {
        if (-e "./configure") {
          safe_system("./configure $DEFAULT_CONFIGURE_ARGS");
        } elsif (-e "./autogen.sh") {
          safe_system("./autogen.sh $DEFAULT_CONFIGURE_ARGS");
        } else {
          die "Don't know how to configure ".$pkg->{'name'};
        }
    }
}

sub make_package {
    my ($pkg) = @_;

    safe_chdir($pkg->{'dirpath'});
    print "Making: ".$pkg->{'name'}."\n";
    if ($pkg->{'make'}) {
        safe_system($pkg->{'make'});
    } else {
        safe_system('make');
    }
}

sub test_package {
    my ($pkg) = @_;

    safe_chdir($pkg->{'dirpath'});
    if ($pkg->{'test'}) {
        print "Testing: ".$pkg->{'name'}."\n";
        safe_system($pkg->{'test'});
    }
}

sub install_package {
    my ($pkg) = @_;

    safe_chdir($pkg->{'dirpath'});
    print "Installing: ".$pkg->{'name'}."\n";
    if ($pkg->{'install'}) {
        safe_system($pkg->{'install'});
    } else {
        safe_system('make','install');
    }
}

sub safe_chdir {
    my ($dir) = @_;
    $dir = $BUILD_DIR unless defined $dir;
    print "Changing to: $dir\n";
    chdir($dir) or die "Failed to change directory: $!";
}

sub safe_system {
    my (@cmd) = @_;
    print "Running: ".join(' ',@cmd)."\n";
    if (system(@cmd)) {
        die "Command failed";
    }
}


# HACK to fix bad gtkdoc detection
sub gtkdoc_hack {
    my ($dir) = @_;
    my $script = "$dir/bin/gtkdoc-rebase";

    open(SCRIPT, ">$script") or die "Failed to open $script: $!";
    print SCRIPT "#/bin/sh\n";
    close(SCRIPT);

    chmod(0755, $script) or die "Failed to chmod 0755 $script: $!";
}
