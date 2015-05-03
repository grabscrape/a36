#!/bin/perl

use v5.10;

use File::Fetch;
use File::Basename;
use English;
use Data::Dumper;
use strict;


my $cache_dir = './Cache0';
say `bash ../rotate/rotate.sh $cache_dir 2>&1`;
mkdir $cache_dir;

#my @links = map { chop $_; $_ } `find Links/hrefs -type f -exec grep ^http '{}' \\;  `;
my @links = map { chop $_; $_ } `cat links0 | head -1000`;

#say Dumper \@links;

foreach my $l ( @links ) {
   #say $l;
   fetch( $l );
#exit 0;
}

exit 0;

### Subs

my $i=1;
sub fetch {

    my $link = shift;
    $i=1 unless $i ;
    printf "$link: ";

    my $basename = basename $link;
    my $file0 = $cache_dir.'/'.$basename.'.html';
    #say $basename, ':', $file0;
#return;

    my $s = -s $file0;
    if( $s ) {
        say "Already [$s]";
        return;
    }

    my $ff = File::Fetch->new( uri => $link );
    my $where = $ff->fetch( to => '/tmp' );
    #say $ff->file;
    #say `ls -lt $where`;

    my $file = $cache_dir.'/'.$ff->file.'.html';
    my $output = `mv $where $file 2>&1`;
    say "Done [$i] $output";
    $i++;
}

