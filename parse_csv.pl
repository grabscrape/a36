#!/bin/perl

use v5.10;

use Text::CSV::Encoded;
use Data::Dumper;
use utf8;
use Encode;
use strict;

my $csv_input = 'a36.uniq.csv'; #$ARGV[0];
die 'Not set cvs file' unless $csv_input;

my @fields0 = ( 
          'Name0',
#'fl1',
'Title',
'Forename',
'Surname',
'after_minus',

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
        );

my $csv = Text::CSV::Encoded->new({ sep_char => '|', encoding=>'latin1', auto_diag=>1, allow_loose_quotes => 1 });

my $line_cnt=0;
my @fields_name=();
my $fields_num;
my @data = ();
my @data2 = ();

open(my $data, "cat $csv_input | head -100000 | " ) or die "Could not open '$csv_input' $!\n";
#open(my $data, '<:encoding(utf8)', "$csv_input" ) or die "Could not open '$csv_input' $!\n";
while (my $line = <$data>) {
#$line =~ s/\xA0/\xC2\xA0/g;

    #$line =~ s/\xA0//g;
    #$line =~ s/\xD6/Oe/g;

    chomp $line;
#say $line;
#next;
 
    if ($csv->parse($line)) {
        if( $line_cnt == 0 ) { 
            @fields_name = $csv->fields();
            $fields_num = scalar @fields_name;
            say "NUmber: $fields_num, ", Dumper \@fields_name;
        } else {
#next if $line !~ m/^Dr. Ingrid Tursky/;
            my @fields = $csv->fields();
            my $f_n = scalar @fields;
            die "illegal $fields_num != $f_n " if $f_n != $fields_num;
            my $tmp = {};
            for( my $i=0; $i < $f_n; $i++ ) {
#say $i, ': ', $fields_name[$i], '=', $fields[$i];
                $tmp->{$fields_name[$i]} = $fields[$i];
            }
            push @data, $tmp;
#say Dumper \@data;
#exit 0;
        }
        $line_cnt++;
        #say "L: $line_cnt";
    } else {
    
      die "$line_cnt: Line could not be parsed: $line\n";
    }
}

my $re1 = qr/^(.*(DDr\.|(?<!f\.\s)Med\.|Dr\.|\bnat\S?|pharm\.|\bPsych\.|oec\.|uXniv\.|stom\.|Mag\.\S{0,2}|phil\.|theol\.|MSc\.?|Prof\.|dent\.))\s*(.*)$/i;

my $re2 = qr/^(.*(DDr\.|(?<!f\.\s)Med\.|Dr\.|\bnat\S?|pharm\.|\bPsych\.|oec\.|uXniv\.|stom\.|Mag\.\S{0,2}|phil\.|theol\.|MSc\.?|Prof\.|dent\.))\s*(.*)$/i;

foreach my $r ( @data ) {
    my $name0 = $r->{Name0};

#next if $name0 ne 'o.Univ.-Prof. Dr. Gerhard Schüssler - Univ.-Klinik f. med. Psychologie und Psychotherapie';
#next if $name0 ne 'Dipl.Med. Brigitte Schulze';
#say $name0;
#exit;
    my $title;
    my $name;
    my $after_minus;
    #if( $name0 =~ m/^(.*(DDr\.|(?<!f\.\s)Med\.|Dr\.|\bnat\S?|pharm\.|\bPsych\.|oec\.|uXniv\.|stom\.|Mag\.\S{0,2}|phil\.|theol\.|MSc\.?|Prof\.))\s*(.*)$/i ) {
    if( $name0 =~ m/$re1/i ) {

        if(0) {
            say 'here1';
            #say $name0;
            say "1: $1";
            say "2: $2";
            say "3: $3";
            say "4: $4";
            exit;
        }

        $title = $1;
        $name = $3;

        if( $name =~ m/^(\s*univ\.)\s+(.*)$/ ) {
            $title .= $1;
            #say "$name0";
            #say "  $title !!";
            $name = $2;
            #say "  $2 : $found";
        } else {
            #say "$1";
#            say $title;
            #say "  $3";
#            say "  $found";
        }
        #say "$name0";
        #say "  $title";
        #say "  $name";

    } else {
        $name = $name0;
        #say "2::$name0";
    }




    my $flag1;
    $flag1 = 1 if $title and $name eq '';



    if( $flag1 ) {
        $r->{fl1}=1;
        #say "name0:$name0";
        #say "  title:$title";
        #say "  name:$name";
        if( $name0 eq $title ) {
            #say '  Equil title';
        } elsif( $name0 eq $name ) {
            say '  Equil name';
            die 'here1';
        } else {
            say '  Other';
            die 'here2';
        }
        
        if( $title =~ m/^(.*)(,?\s+|\s+-\s+)(MSc.*)?MSc$/ ) {

            # Dr. med. dent. Robert Bauder, MSc MSc 
            my $tmp = $1;
            $tmp =~ s/, MSc//;
            $tmp =~ s/(,\s*|\s*-\s*|\s*)$//;

            #say "  Found1:", $tmp;
            #say "  Found2:", $2;
            #say "  Found3:", $3;

            $title .= " Msc";
            $name = $tmp;


            if( $name =~ m/$re2/i ) {
                #say '1: ', $1;
                #say '2: ', $2;
                #say '3: ', $3;
                #say '4: ', $4;
                #say '5: ', $5;
                if( $1 eq $title ) {
                    $r->{fl1} = '11';
                    $title = 'Some'; #$1. ' MSc';
                } else {
                    $title = $1. ' MSc';
                }


                $name = $3;
            } else {
                    $title = 'MSc';
                    $name =~ s/MSc\s*//g;
                    $r->{fl1} = '22';
            }
        } else {
                    $r->{fl1} = '33';
            #next;
        }
    } else {
                    #$r->{fl1} = '44';
    }



    ## looking for minus in name;
    $r->{Title} = $title if $title;

    if( $name =~ m/^(.*?)\s+-\s+(.*)$/ ) {
        $name = $1;
        $after_minus = $2;
        $r->{after_minus} = $after_minus;
    }



    if( $name =~ m/(.*)\s+(\S+)$/ ) {
        $r->{Forename} = $1;
        $r->{Surname} = $2;
    } else {
        $r->{Forename} = $name;
    }

#say Dumper $r;
    push @data2, $r ; #if $flag1; # or $r->{fl1} eq '44';
}

#say Dumper \@data;


open CSV, ">a36.csv";
say CSV join '|', @fields0;
foreach my $d (@data2) {
    say CSV join '|', map {
        $d->{$_} || ''
    } @fields0;
}
close CSV;

my $o=`python /home/selenium/ch19/csv2excel.py --sep '|' --title --output ./a36.xls ./a36.csv`;

say "Py output: $o" if $o;

exit 0
