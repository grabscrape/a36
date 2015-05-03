#!/bin/perl

use v5.10;

use File::Fetch;
use File::Basename;
use English;
use Data::Dumper;
use Mojo::DOM;
use strict;


my $site_root = 'http://www.wo-in-tirol.at/';
my $cache_dir1 = './Cache1';
say `bash ../rotate/rotate.sh $cache_dir1 2>&1`;
mkdir $cache_dir1;

my @links = map { chop $_; $_ } `find Cache0/ -type f -name \\*html `;
#my @links = `find Cache0/ -type f -name \\*html `;

#say Dumper \@links;

foreach my $l ( @links ) {
#   say $l;
   fetch_level2( $l );
#exit 0;
}

exit 0;

### Subs
my $count=1;
sub fetch_level2 {

    my $link = shift;
    $count=1 unless $count;
    printf "$link: ";
#    say ;

    my $content = `cat $link`;
    say length $content;

    my $dom = Mojo::DOM->new($content);

    my $regions = $dom->find('nav#regionnav li');

    say 'N Regions: ', scalar @$regions;

    for( my $i=0; $i<scalar @$regions; $i++ ) {
        my $el = $regions->[$i];
        my $region_name;
        if( $i==0 ) {
            $region_name = $el->text;
            #say "1st page. Region name: $region_name";

            my $file1 = basename($link);
            $file1 =~ s/\.html//;
            $file1 = $cache_dir1.'/'.$file1.".${region_name}.01.html";
            my $cp_output = `cp $link $file1 2>&1`;
            say "Done1 [$count] $cp_output";
            $count++;
        } else {
            #say "$i: ", $el->at('a')->text;
            $region_name = $el->at('a')->text;
            my $region_link = $el->at('a')->attr('href');
            say "Regionname: $region_name";
            say "Regionlink: $region_link";
            handle_pages($dom, $region_name, $link, $content );
        }
    }

}

sub handle_pages {
    my $dom = shift;
    my $region_name = shift;
    my $link = shift;
    my $content = shift;

    my $pages = $dom->find('ul.f3-widget-paginator li');
    say $region_name, ':', 'Pages = ', scalar @$pages;
    #return;

    for( my $i=0; $i<scalar @$pages; $i++ ) {
        my $uplevel = basename $link;
        $uplevel =~ s/\.html//;
        my $filename="${uplevel}.$region_name.". (sprintf( '%02d', $i+1));
        #say "SP: ", sprintf( '%02d', $i+1);
        #say "Filename: $filename";
        if( $i==0 ) {
            say 'First page';
        } else {
#return if $i >=2;
            my $href0 = $pages->[$i]->at('a')->attr('href');
            my $atext = $pages->[$i]->at('a')->text;
            next if $atext eq 'next';
            say "Region: $region_name. Page: ", $i+1, ". Text: $atext"; #, $pages->[$i]->at('a')->attr('href');
            $href0 = $site_root.$href0;
            fetch_file( $href0, $filename );
        }
    }
}

sub fetch_file {
    my $link = shift;
    my $filename = shift;

    my $file = $cache_dir1.'/'.$filename.'.html';

    my $s = -s $file;
    if( $s ) {
        say "Already [$s]";
        return;
    }
    
    #$link = 'http://mail.ru/index.html';
#say "LINK: $link";
#say "Filename: $filename";

    my $ff = File::Fetch->new( uri => $link ) or die "Error: $!";
    my $where = $ff->fetch( to => '/tmp/' ) or die "Error2: $!";
    #say "FF:file: ", $ff->file;
    #say "Where: ";
    #say `ls -lt $where`;
    #say 'File: ', $file;
    my $output = `mv $where $file 2>&1`;
    say "Done [$count] $output";
    $count++;
}


__END__

