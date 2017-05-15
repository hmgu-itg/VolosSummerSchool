open INPUT, "$ARGV[0]" or die "Unable to open Input file\n";
open OUTPUT, ">tab-$ARGV[0]" or die "Unable to open output file\n";
while (<INPUT>)
 {
 chomp;
 s/^\s+//;
 s/\s+/\t/g;
 print OUTPUT "$_\n";
 }