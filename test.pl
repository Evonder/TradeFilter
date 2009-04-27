$req = Win32::GetCwd();
opendir(DIR ,"$req") or die "cannot open $req";
$outfile = "list.txt";
open OUT, ">$outfile" or die "Cannot open $outfile";
 
while (defined($doc = readdir(DIR)))
{        
  if($doc eq "\." || $doc eq "\..")
 {
                #do nothing;
 }
  else
  {
    if ($doc =~/\.JPG/)
    {
      print OUT "$doc,$ARGV[0],$ARGV[1]\n";
     
    }
    else
   {    
          
    #do nothing;
 
   }
 }
} 