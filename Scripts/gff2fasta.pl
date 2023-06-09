#!/usr/bin/perl
use strict;
#use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::DB::Fasta;

$| = 1;    # Flush output
my $outfile_cds = Bio::SeqIO->new( -format => 'fasta', -file => ">$ARGV[2].cds.fasta" );
my $outfile_pep = Bio::SeqIO->new( -format => 'fasta', -file => ">$ARGV[2].pep.fasta" );
my $outfile_cdna = Bio::SeqIO->new( -format => 'fasta', -file => ">$ARGV[2].cdna.fasta" );
my $outfile_gene = Bio::SeqIO->new( -format => 'fasta', -file => ">$ARGV[2].gene.fasta" );
my $outfile_upstream3000 = Bio::SeqIO->new( -format => 'fasta', -file => ">$ARGV[2].upstream3000.fasta" );

###### Output type description ######
# cds - translated sequence (starting with ATG and ending with a stop codon included)
# cdna - transcribed sequence (devoid of introns, but containing untranslated exons)
# protein - cds translated (includes a * as the stop codon)
# gene - the entire gene sequence (including UTRs and introns)
# upstream3000 - the 3000 upstream region of the gene (likely including the promoter)

### First, index the genome
my $file_fasta = $ARGV[0];
my $db = Bio::DB::Fasta->new($file_fasta);
print ("Genome fasta parsed\n");



### Second, parse the GFF3
my %CDS;
my %CDNA;
my $mRNA_name;
my $frame;
open GFF, "<$ARGV[1]" or die $!;
while ( my $line = <GFF> ) {
    chomp $line;
    my @array = split( "\t", $line );
    my $type = $array[2];

    if ($type eq 'gene') {
        my @attrs = split( ";", $array[8] );
        $attrs[0] =~ s/ID=//;
        my $gene_name = $attrs[0];
        my $gene_start = $array[3];
        my $gene_end = $array[4];
        my $gene_seq = $db->seq( $array[0], $gene_start, $gene_end );
        my $output_gene = Bio::Seq->new(
            -seq        => $gene_seq,
            -id         => $gene_name,
            -display_id => $gene_name,
            -alphabet   => 'dna',
        );


        # The upstream 3000
        my $upstream_start;
        my $upstream_end;
        if($array[6] eq '+') {
            $upstream_start=$gene_start-3000;
            $upstream_end=$gene_start-1;
        }
        elsif ($array[6] eq '-') {
            $upstream_start=$gene_end+1;
            $upstream_end=$gene_end+3000;
        }
        my $upstream_seq = $db->seq( $array[0], $upstream_start, $upstream_end );
        my $output_upstream3000 = Bio::Seq->new(
            -seq        => $upstream_seq,
            -id         => $gene_name."_upstream3000",
            -display_id => $gene_name."_upstream3000",
            -alphabet   => 'dna',
        );

        # Reverse Complement if the frame is minus
        if($array[6] eq '+') {
        }
        elsif ($array[6] eq '-') {
            $output_gene = $output_gene->revcom();
            $output_upstream3000 = $output_upstream3000->revcom();
        }
        else {
            die "Unknown frame! At line $. of the GFF\n";
        }
        $outfile_gene->write_seq($output_gene);
        $outfile_upstream3000->write_seq($output_upstream3000);
    }


    if ( ( $type eq 'mRNA' ) and ( $. > 2 ) ) {
        # CDS: Collect CDSs and extract sequence of the previous mRNA
        my $mergedCDS_seq;
        # WARNING we must sort by $cds_coord[1]


        foreach my $key (sort {$a <=> $b} keys %CDS) { # Ascending numeric sort of the starting coordinate
            my $coord = $CDS{$key};
            my @cds_coord = split( " ", $coord );
            my $cds_seq = $db->seq( $cds_coord[0], $cds_coord[1], $cds_coord[2] );
            $mergedCDS_seq .= $cds_seq;
        }

        my $output_cds = Bio::Seq->new(
            -seq        => $mergedCDS_seq,
            -id         => $mRNA_name,
            -display_id => $mRNA_name,
            -alphabet   => 'dna',
        );
        if ($frame eq '-') {
            $output_cds = $output_cds->revcom();
        }
        my $output_pep = $output_cds->translate();
        $outfile_cds->write_seq($output_cds);
        $outfile_pep->write_seq($output_pep);


        # CDNA: Collect UTRs and CDSs and extract sequence of the previous mRNA
        my $mergedCDNA_seq;
        foreach my $key (sort {$a <=> $b} keys %CDNA) { # Ascending numeric sort of the starting coordinate
            my $coord = $CDNA{$key};
            my @cds_coord = split( " ", $coord );
            my $cds_seq = $db->seq( $cds_coord[0], $cds_coord[1], $cds_coord[2] );
            $mergedCDNA_seq .= $cds_seq;
        }

        my $output_cdna = Bio::Seq->new(
            -seq        => $mergedCDNA_seq,
            -id         => $mRNA_name,
            -display_id => $mRNA_name,
            -alphabet   => 'dna',
        );
        if ($frame eq '-') {
            $output_cdna = $output_cdna->revcom();
        }
        $outfile_cdna->write_seq($output_cdna);



        # Now initialize the next mRNA
        my @attrs = split( ";", $array[8] );
        $attrs[0] =~ s/ID=//;
        $mRNA_name = $attrs[0];
        $frame=$array[6];
        %CDS = (); %CDNA = (); # Empty the chunk arrays
    }
    elsif ( $type eq 'mRNA' ) {    # First mRNA
        my @attrs = split( ";", $array[8] );
        $attrs[0] =~ s/ID=//;
        $mRNA_name = $attrs[0];
        $frame=$array[6];
    }
    elsif ( $type eq 'CDS' ) {
        my $cds_coord = $array[0] . " " . $array[3] . " " . $array[4];
        $CDS{$array[3]}=$cds_coord;
        $CDNA{$array[3]}=$cds_coord;
    }
    elsif ($type eq 'UTR' ) {
        my $utr_coord = $array[0] . " " . $array[3] . " " . $array[4];
        $CDNA{$array[3]}=$utr_coord;
    }

}

close GFF;
