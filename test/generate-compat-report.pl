#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
use TAP::Parser;
use Data::Dumper;
use Scalar::Util qw(blessed);
use Sort::Key::Natural qw(natsort);
use Text::FormatTable;
use List::Util qw(max);

use open ':std', ':encoding(UTF-8)';

my %os_trans = (
    "[aA]lpine"                 => "'Alpine Linux'",
    "[oO]pensuse"               => "'OpenSUSE'",
    "[mM]adworx/debian-archive" => "'Debian'",
    "[cC]entos"                 => "'CentOS'",
    "[nN]etbsd"                 => "'NetBSD'",
    "[oO]sx"                    => "'MacOS X'",
    "^([a-z])"                  => "ucfirst(\$1)",
    );

my %os_ver_trans = (
    "-slim\$"                 => "''",
    "-x86_64\$"               => "''",
    "^([a-z])"                => "ucfirst(\$1)",
    );

my %os_name_trans = (
    "Debian Etch"             => [ "Debian 4.0 (Etch)", ],
    "Debian Lenny"            => [ "Debian 5.0 (Lenny)", ],
    "Debian Squeeze"          => [ "Debian 6.0 (Squeeze)", ],
    "Debian Wheezy"           => [ "Debian 7 (Wheezy)", ],
    "Debian Jessie"           => [ "Debian 8 (Jessie)", ],
    "Debian Stretch"          => [ "Debian 9 (Stretch)", ],
    "Debian Buster"           => [ "Debian 10 (Buster)", ],
    "Debian Sid"              => [ "Debian unstable (Sid)", ],
    "Ubuntu Precise"          => [ "Ubuntu 12.04 LTS (Precise)", ],
    "Ubuntu Trusty"           => [ "Ubuntu 14.04 LTS (Trusty)", ],
    "Ubuntu Xenial"           => [ "Ubuntu 16.04 LTS (Xenial)", ],
    "Ubuntu Yakkety"          => [ "Ubuntu 16.10 (Yakkety)", ],
    "Ubuntu Zesty"            => [ "Ubuntu 17.04 (Zesty)", ],
    "Ubuntu Artful"           => [ "Ubuntu 17.10 (Artful)", ],
    "Ubuntu Bionic"           => [ "Ubuntu 18.04 LTS (Bionic)", ],
    );

my %os_category_desc = (
    "Alpine Linux" => "Alpine",
    "Bash"         => "Multiple versions of the \`bash\` shell, compiled and run on [debian/buster](https://wiki.debian.org/DebianBuster).",
    "CentOS"       => "CentOS",
    "Debian"       => "[Current](https://www.debian.org/releases/) and [old/archived](https://hub.docker.com/r/madworx/debian-archive/) versions of the Debian GNU/Linux operating system.",
    "NetBSD"       => "The [NetBSD](http://www.netbsd.org) operating system, using the [madworx/netbsd](https://hub.docker.com/r/madworx/netbsd/) docker images.",
    "OpenSUSE"     => "OpenSUSE",
    "Ubuntu"       => "Ubuntu",
    "MacOS X"      => "Apple MacOS X"
    );

my $parser = TAP::Parser->new( { source => $ARGV[0] } );

my %shells;
my %oses;

while ( my $result = $parser->next ) {
    if ( blessed $result eq 'TAP::Parser::Result::Test' ) {
        my ( $os_category, $os_version, $shell, $shell_version) = ($result->description =~ /([^:]+):([^ ]+) ([^:]+):(.*)/);

        while ( my ($key, $value) = each (%os_trans)) {
            $os_category =~ s/$key/$value/ee;
        }
        while ( my ($key, $value) = each (%os_ver_trans)) {
            $os_version =~ s/$key/$value/ee;
        }
        my $osdescr = $os_category." ".$os_version;
        while ( my ($key, $value) = each (%os_name_trans)) {
            $osdescr =~ s/$key/$value->[0]/e;
        }

        $oses{$os_category}{$osdescr}{$shell}{$shell_version} = $result->ok;
        $shells{$os_category}{$shell} = 1;    
    }
}

my @out;
print "# Shell and operating system compatability report\n\n";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
my $commit;
($commit = "[".`git describe --tags --always`."](https://github.com/madworx/docshell/commit/".`git log --format="%H" -n 1`.").") =~ s/\n//msg;
printf("This report was generated at %04d-%02d-%02d %02d:%02d:%02d, from git commit %s\n\n", 1900+$year,$mon+1,$mday,$hour, $min, $sec,$commit);

foreach my $os_category ( natsort keys %oses ) {
    my @oses   = reverse natsort( keys %{$oses{$os_category}} );
    my @shells = natsort( keys %{$shells{$os_category}} );
    my @header = ( "Operating system", @shells );
    my @out = ();
    foreach my $os ( @oses ) {
        my @row = ($os);
        foreach my $shell ( @shells ) {
            my $str = "";
            foreach my $testedversion( reverse natsort keys %{$oses{$os_category}{$os}{$shell}} ) {
                if ( $oses{$os_category}{$os}{$shell}{$testedversion} eq 'ok' ) {
                    $str .= "\x{2705}";
                } else {
                    $str .= "\x{274c}";
                }
                $str .= $testedversion.", ";
            }
            $str =~ s/, $//;
            push( @row, $str );
        }
        push( @out, [ @row ] );
    }
    my $osnlen = (max map { length } ( @oses, $header[0] ));
    my $fmtstr = '| '.$osnlen."l |"." l |"x(scalar @header - 1);

    print "## ".$os_category."\n";
    print $os_category_desc{$os_category}."\n" if $os_category_desc{$os_category};
    print "\n";
    my $table = Text::FormatTable->new( $fmtstr );
    $table->head(@header);
    $table->rule('-');
    foreach( @out ) {
        $table->row( @{$_} );
    }
    my $tabtxt = $table->render();
    my $tabmd;
    ($tabmd = $tabtxt) =~ s/(^|-)[+](-|$)/$1|$2/msg;
    print $tabmd."\n\n\n";
}
