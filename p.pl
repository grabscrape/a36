#!/usr/bin/perl

use v5.10;
use Data::Dumper;
use strict;

my $name0='o.Univ.-Prof. Dr. Gerhard Schüssler - Univ.-Klinik f. med. Psychologie und Psychotherapie';
#my $name0='k f. med. Ps';


    if( $name0 =~ m/^(.*(DDr\.|(?<!f\.\s)med\.|Dr\.|\bnat\S?|pharm\.|\bPsych\.|oec\.|uXniv\.|stom\.|Mag\.\S{0,2}|phil\.|theol\.|MSc\.?|Prof\.))\s*(.*)$/i ) {
    #if( $name0 =~ m/^(.*((?<!f\.\s)med\.))\s*(.*)$/ ) {
        say $name0;
        say "  1: $1";
        say "  2: $2";
        say "  3: $3";
    } else {
        say 'else';
    }
