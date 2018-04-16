#! /usr/bin/perl

use utf8;
use TAP::Parser;
use Data::Dumper;
use Scalar::Util qw(blessed);
use Sort::Key::Natural qw(natsort);
#use Text::Table::Tiny 0.04 qw/ generate_table /;
use Text::FormatTable;
use List::Util qw(max);

use open ':std', ':encoding(UTF-8)';

my %os_trans = (
    "[aA]lpine"                 => "'Alpine Linux'",
    "[oO]pensuse"               => "'OpenSUSE'",
    "[mM]adworx/debian-archive" => "'Debian'",
    "[cC]entos"                 => "'CentOS'",
    "[nN]etbsd"                 => "'NetBSD'",
    "^([a-z])"                  => "ucfirst(\$1)",
    );

my %os_ver_trans = (
    "-slim\$"                 => "",
    "-x86_64\$"               => "",
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

my $parser = TAP::Parser->new( { source => $ARGV[0] } );

my %shells;
my %oses;

while ( my $result = $parser->next ) {
    if ( blessed $result eq 'TAP::Parser::Result::Test' ) {
        my ( $os_category, $os_version, $shell, $shell_version) = ($result->description =~ /([^:]+):([^ ]+) ([^:]+):(.*)/);

        while (($key, $value) = each (%os_trans)) {
            $os_category =~ s/$key/$value/ee;
        }
        while (($key, $value) = each (%os_ver_trans)) {
            $os_version =~ s/$key/$value/ee;
        }
        $osdescr = $os_category." ".$os_version;
        while (($key, $value) = each (%os_name_trans)) {
            $osdescr =~ s/$key/$value->[0]/e;
        }

        $oses{$os_category}{$osdescr}{$shell}{$shell_version} = $result->ok;
        $shells{$os_category}{$shell} = 1;    
    }
}

my @out;
print "# Shell and operating system compatability report\n\n";
foreach my $os_category ( natsort keys %oses ) {
    @oses   = reverse natsort( keys %{$oses{$os_category}} );
    @shells = natsort( keys %{$shells{$os_category}} );
    my @header = ( "Operating system", @shells );
    my @out = ();
    foreach my $os ( @oses ) {
        my @row = ($os);
        foreach my $shell ( @shells ) {
            $str = "";
            foreach my $testedversion( reverse natsort keys %{$oses{$os_category}{$os}{$shell}} ) {
                if ( $oses{$os_category}{$os}{$shell}{$testedversion} eq 'ok' ) {
                    $str .= "\x{2713}";
                } else {
                    $str .= "\x{2715}";
                }
                $str .= $testedversion.", ";
            }
            $str =~ s/, $//;
            push( @row, $str );
        }
        push( @out, [ @row ] );
    }
    $osnlen = (max map { length } ( @oses, $header[0] ));
    $fmtstr = '| '.$osnlen."l |"." l |"x(scalar @header - 1);

    print "## ".$os_category."\n";
    my $table = Text::FormatTable->new( $fmtstr );
    $table->head(@header);
    $table->rule('-');
    foreach( @out ) {
        $table->row( @{$_} );
    }
    $tabtxt = $table->render();
    ($tabmd = $tabtxt) =~ s/-[+]-/-|-/g;
    print $tabmd."\n\n";
}
