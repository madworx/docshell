#!/usr/bin/perl

use Text::Diff;

$/="\n\n";

while( <> ) {
    chomp;
    s/\r//g;
    @_ = split /\n/;
    next if $_[0] =~ /^Testing/;
    ( $exit_code, $os, $shell ) = split( / /, $_[0] );

    shift @_;
    $command_output = join("\n",@_);
    $command_output =~ s/^# //msg;

    if ( $exit_code == 0 ) {
        my $diff = diff "example.expect", \$command_output;
        if ( $diff ne '' ) {
            $diff =~ s/^|\n/\n# /sg;
            $str = "not ok ".$os." ".$shell.$diff;
            push( @results, $str )
        } else {
            push( @results, "ok ".$os." ".$shell );
        }
    } else {
        $str = "not ok ".$os." ".$shell."\n";
        $str .= "# Wrong exit code: ".$exit_code."\n";
        push( @results, $str )
    }
    
}

$str = "";
$str .= "1..".@results."\n";
foreach( @results ) {
    $str .= $_."\n";
}

print $str;
