use strict;
use warnings;
use Data::Dumper;
	
my $ma_file	=$ARGV[0];
my $inclusion_file	=$ARGV[1];
my $output_file	=$ARGV[2];

open my $META,"<", $ma_file or die "Can't open $ma_file: $!";
open my $INCLUSION,"<", $inclusion_file or die "Can't open $inclusion_file: $!";
open my $OUT,">", $output_file or die "Can't open $output_file: $!";

my %inclusion;
while (my $rsID=<$INCLUSION>){
	chomp $rsID;
	$inclusion{$rsID}=1;
}
close $INCLUSION;


while (my $line=<$META>){
	chomp $line;
	my @columns = split /\s/, $line ;
	my $rsID=$columns[0];
	if($inclusion{$rsID}){
	 print $OUT $line, "\n";
	}
}



