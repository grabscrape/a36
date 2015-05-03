#!/bin/perl

use v5.10;

use File::Fetch;
use Data::Dumper;
use Mojo::DOM;
use Encode;
use strict;


my @fields = (
    'Name0',
    'Street',
    'Postcode',
    'City',
    'Disctrict',
    'Telefon',
    'Fax',
    'Email',
    'Web',
    'Practice',

    'Setting',
    'Zielgruppen',
    'Diplome',
    'Sprachen',
    'Angebote',
    'Zertifikate',
    'unnamed',
    'URL'
    

          #'Practice' => 'Psychotherapie',
          #'Name0' => 'Bernadette Schönherr',
          #'Street' => 'Untermarkt 9',
          #'City' => 'Telfs',
);

my $cache_dir = './Cache2';
#my @links = map { chop $_; $_ } `find Cache2/ -type f -name \\*html | grep psychotherapie.Kitzbühel.03.8.renate-lichtenauer-6130-schwaz.html`;
my @links = map { chop $_; $_ } `find $cache_dir/ -type f -name \\*html | head -1000000 | grep -vE 'Xpraktischer-arzt-allgemeinmediziner.Tirol.01.4.dr-iris-steiner-6631-lermoos.html|Xpsychotherapie.Kitzbühel.03.8.renate-lichtenauer-6130-schwaz.html'`;

my $gnum=0;
my @data = ();

foreach my $l ( @links ) {
    #say $l;
    parse( $l );
    push @data, parse( $l );
#exit 0;
}


open CSV, ">a36.csv";
say CSV join '|', @fields;
foreach my $d (@data) {
    say CSV join '|', map {
        $d->{$_} || ''
    } @fields;
}

close CSV;


my %items;
###
sub parse {

    my $file = shift;
    $gnum++;
    my $data = {};

    #print "File: $file ::";
    my $body;
    open FD, $file or die "Error: $!";
    $body .= $_ for <FD>;
    close FD;

    my $url;
    if( $body =~ m/^(http:.*)\Z$/m ) {
        #say "File: $file";
        #say "URL: $1"
        $url =$1;
    } else {
        die 'Not found link';
    }
    $data->{URL} = $url;
    #$body = encode('utf8',$body);

#$$body =~ s/&Ouml;/HHEERREE/g;
#$body =~ s/&nbsp;/space/g;


#    say $body;

    my $dom = Mojo::DOM->new( $body );
    my $art = $dom->find('article')->[0];

    my $check=$dom->find('div.csc-default'); 
    my $check_n = scalar @$check;

    my( $flag, $cat, $par1, $par2, $tags );
    if( $check_n == 0 ) { 
        $flag='0';
        #say "I NOT find csc: ", $check_n;
        $cat = $dom->find('div#main ul.categories')->[0];

        $par1 = $cat->next; # say "par; ", $cat->next;
        #$par2 = $cat->next->next; #say "par2; ", $cat->next->next;
        #$tags = $dom->find('div#main ul.tags')->[0];


    } elsif( $check_n == 3 ) {
        $flag='3';
        #print "I find csc:     ", $check_n;

        $cat = $dom->find('div.csc-default ul.categories')->[0]; #->[2]; #.categories')->[0];

        $par1 = $cat->next; # say "par; ", $cat->next;
        #$par2 = $cat->next->next; #say "par2; ", $cat->next->next;
        #$tags = $dom->find('div.csc-default ul.tags')->[0];

    } else {
        die "error analyse csc-check";
    }



    #say $art;
    my $name0 = $art->at('h1')->text;
    $data->{Name0} = $name0;

#    my( $name1, $rest ) = split /-/, $name0;
#    $name1 =~ s/^\s+//;
#    $rest =~ s/^\s+//;

#say "=$name1=", ( $rest ? "\t\t\tafter-minus:".$rest : '');
#say "  =$rest=" if $rest;
#next;
    #say 'Adr: ', $art->at('p.adr');
    my $street   = $art->at('p.adr span.street-address')->text;
    $data->{Street} = $street;

    my $postcode = $art->at('p.adr span.postal-code')->text;
    $data->{Postcode} = $postcode;

    my $city = $art->at('p.adr span.locality')->text;
    $data->{City} = $city;

    my $tel = $art->find('p.tel'); # span');
    my $tel_n = scalar @$tel;
    #say "TEL: ", $tel_n, " : ", join ',', @$tel;

    for( my $i=0; $i< $tel_n; $i++ ) {
        #say '1: ', $tel->[$i];
        my $contact_type = $tel->[$i]->find('span.type')->map(attr=>'title')->[0];
        my $contact      = $tel->[$i]->find('span.value')->[0]->text; #|map(attr=>'title')->[0];
        if( $contact_type eq 'voice' ) {
            $data->{Telefon} = $contact;
        } elsif( $contact_type eq 'fax' ) {
            $data->{Fax} = $contact;
        } else {
            die "Unnknown contact: $contact_type , $contact";
        }
        #say $contact_type, ' : ', $contact;
    }
 
    my $email = $art->at('p.email a');
    if( $email ) { $email = $email->text; $email =~ s/@\s+/@/; $data->{Email} = $email; }
    #$data->{Email} = $email if $email;
    #say "Email: $email";

    my $web = $art->at('p.url a');
    if( $web ) { $web = $web->text; $data->{Web} = $web } #; $web =~ s/@\s+/@/; }
    #say "Web: ", $web if $web;

    my @adr_br = split /<\s*br\s*\/?>/, $art->at('p.adr');
    my $adr_br_n = scalar @adr_br;
    my $last_addr = $adr_br[$adr_br_n-1];

    $last_addr =~ s/<\/p>//;
    $last_addr =~ s/\n//g;
    my $district = $last_addr;
    $district =~ s/<\/?span.*?>//g;


    #$district =~ s/\x0D//g;
    #say "Last  addr: ", $last_addr; 

    $data->{Disctrict} = $district;
    #my $dom1 = Mojo::DOM->new( $last_addr );

    #say 'Fin: ', Dumper $dom1->text;
    #say Dumper \@adr_br;

    #$cat = $cat.'';
    my $li = $cat->find('li');
    my $li_n = scalar @$li; 
    my @li1 = map { $_->text } @$li;


    my $practice = join ', ', @li1;
    #say "\tflag:$flag, [$li_n]:",
    $data->{Practice} = $practice;

#next unless $name0 eq 'Dr.phil. Verena Auer';



if(0) {
    say; 
    #say "File: $file";
    say "URL: ", $url;
    say '  Name1: ', $name0;
    #say '  after_minus: ', $rest if $rest;
    say '  Street: ', $street;
    say '  Postcode: ', $postcode;
    say '  City: ', $city;
    say "  District: ", $district;
    say "  Practice: $practice"; #join ' ** ', @li1; 
}
    # $data->{practice} = $practice;

    if( 1 && $par1->type eq 'p' ) { 
        $par1 = $par1.'';

        #die "${par1}:::not p" if not $par1 =~ m/<\/?p>/;

        $par1 =~ s/\x0D//g;
        $par1 =~ s/<\/?p>//g;
        #say "Par1: ", $par1; #->all_text(0);
        my @items = split /<\s*br\s*\/?>/, $par1;

        if( @items ) {
            foreach my $i0 ( @items ) {
                my ($item_name,$item_value) = split /\s*:\s*/, $i0;
                unless( $item_value ) {
                    $data->{unnamed} = $item_name;
                    #say '    ** Unnamed: ', $item_name;
                } else {
                    $data->{$item_name} = $item_value;

                    if( not exists $items{$item_name}) {
                        say "Item: $item_name";
                        $items{$item_name}=1;
                    }
                    #say "    $item_name: $item_value";
                    
                }
            }

            #my $diplomas = join ' ', @items;
            #say "\tDiplomas: $diplomas";

            #my $diplomas = shift @items;
            #say "Practice: $practice";
            #say Dumper \@items;
        }
    }

    #say Dumper $data;
    return $data;
    
}
