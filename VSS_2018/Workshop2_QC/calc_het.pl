#!/usr/bin/perl

use Getopt::Std;

getopts('f:p:m:sh', \%options) or usage();

if ($options{'h'})
 {
 usage();
 }
if ($options{'s'})
 {
 #snptest file
 if ($options{'f'})
  {
  $gen_file = $options{'f'}.'.gen';
  $samp_file = $options{'f'}.'.samp';
  
  }
 else
  {
  usage();
  }
 get_gen_data($gen_file, $samp_file); 
 }
else 
 {
 #ped file
 
 if ($options{'f'})
  {
  if ($options{'f'} =~ /(.*?)\.ped$/)
   {
   $ped_file = $options{'f'};
   $map_file = $1.'map';
   }
  else
   {
   $ped_file = $options{'f'}.'.ped';
   $map_file = $options{'f'}.'.map';
   }
  }
 elsif ($opt_p and $opt_m)
  {
  $ped_file = $options{'p'};
  $map_file = $options{'m'};
  }
 else
  {
  usage();
  }
  
 get_ped_data($ped_file, $map_file); 
  
 }


sub usage()
 {
 print "Usage:\n";
 print "perl calc_het.pl -f <filename> -p -m -s\n";
 print "-f specifies the filename to use, if -s is also specified then\n";
 print "   the program expects .gen and samp snptest format \n";
 exit;
 }

sub get_ped_data(\$\$)
 {
 open OUTPUT, ">Summary-$ped_file" or die;
 print OUTPUT "ID\ttotal\t# hom\t# het\t% hom\t% het\n";
 my $ped_file = $_[0];
 my $map_file = $_[1];
 my $i = 0;
 
 #open MAP, "$map_file" or die;
 #while (<MAP>)
 # {
 # @temp = split/\t/;
 # $rs[$i] = $temp[1];
 # $i++;
 # }
 #close MAP;
 
 open PED, "$ped_file" or die;
 while (<PED>)
  {
  chomp;
  @temp = split/\s+/;
  $total = 0;
  $het = 0;
  $hom = 0;
  $hom_p = 0;
  $het_p = 0;
  
  for ($i = 6,; $i <= $#temp; $i+=2)
   {
   $allele1 = $temp[$i];
   $allele2 = $temp[$i+1];
   if ($allele1 ne $allele2)
    {
    $het++;
    $total++;
    }
   else
    {
    if ($allele1 eq '0' or $allele eq 'N')
     {
     
     }
    else
     {
     $hom++;
     $total++;
     }
    }
   }
  
  if ($total != 0)
   {
   $hom_p = sprintf("%.2f", $hom/$total*100);
   $het_p = sprintf("%.2f", $het/$total*100);
   }
  print OUTPUT "$temp[0]\t$total\t$hom\t$het\t$hom_p\t$het_p\n"; 
  }
 }


sub get_gen_data(\$\$)
 {
 open OUTPUT, ">Summary-$ped_file" or die;
 
 print OUTPUT "ID\ttotal\t# hom\t# het\t% hom\t% het\n";
 
 my $gen_file = $_[0];
 my $samp_file = $_[1];
 my $i = 0;

 open SAMP, "$samp_file" or die;
 
 while (<SAMP>)
  {
  @temp = split/\s+/;
  $samp[$i] = $temp[1];
  $i++;
  }
 close SAMP;
 
 
 
 
 }