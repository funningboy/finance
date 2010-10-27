 #!/usr/bin/perl 

package NET::TraderDetail;
  use LWP::UserAgent;
  use Data::Dumper;
  use HTML::TableExtract;
  use XML::Simple;
  use strict;
  use Switch;
  
  @NET::TraderDetail::Arr;
 
sub get_help{
    my ($case,$data_t,$sys_t) = (@_);
    
    switch($case){
      case "get_date_info" { printf("<E1> the system time not match trader data time error ...                  \
                                          please check the system time @ env or check the trader data in yuanta \
                                          system time @ $sys_t,  yuanta time @ $data_t\n");                         }
   }

die;
}

sub new {
  my $self = shift;
  return bless {};	
} 

sub get_trader_data {
  
     my $ua = LWP::UserAgent->new;
        $ua->agent("MyApp/0.1");
    
      my $MyWebInf = "http://justdata.yuanta.com.tw/z/ze/zee/zee.asp.htm";
  # Create a request
     my $req = HTTP::Request->new(GET => $MyWebInf);
  
   # Pass request to the user agent and get a response back
     my $res = $ua->request($req);

  # Check the outcome of the response
     my $MyHTMLPtr;
     
     if ($res->is_success) {
        $MyHTMLPtr = $res->content;
        ParseHtml2Arr($MyHTMLPtr); 
 
     }else {
     	  print  $res->status_line."\n";
          die;
    }
}

sub ParseHtml2Arr {  
    my ($MyHTMLPtr) = (@_);
  
    my $CDate = get_sys_time();
    my $Date;
 
    if($MyHTMLPtr=~ m/最後更新日: (\w+)\/(\w+)/){
    	 $Date = $1."\/".$2;
      }

    unless($CDate eq $Date){ get_help("get_date_info",$Date,$CDate); }
     
    $MyHTMLPtr =~ s/\,//g;
     
    my $te = HTML::TableExtract->new(depth => 2, count => 0);
       $te->parse($MyHTMLPtr);
    
     my ($ts,$row,$i) = {};
     
     foreach $ts ($te->tables) {
       #print "Table (", join(',', $ts->coords), "):\n";
         foreach $row ($ts->rows) {
         # print Dumper(\$row);
          if($i>=2){
             push(@NET::TraderDetail::Arr,$row);
          }
           $i++;
          }
   	}
 } 	
 
sub exp_trader_data {
 	  my ($self,$Locfile) = (@_);
 	  
 	  if(-e $Locfile){ open( oFilePtr, ">$Locfile") or die "$!\n"; }
 	  else{            open( oFilePtr, ">>$Locfile") or die "$!\n"; }
  
 	   my ($STID,$STNM,$BySlTC,$HDTC,$PCTC) = {};
 	  
 	   foreach my $i (@NET::TraderDetail::Arr){
 	   	  ($STID,$BySlTC,$HDTC,$PCTC) = (@{$i});
 	   	   if( $STID=~ m/(\d+)/){ ($STID,$STNM) = ($1,$2); $STID=$STID.".TW"; }
 	   	  	  printf  oFilePtr ("$STID,$BySlTC,$HDTC,$PCTC\n");  
 	   	}
}
 
sub get_sys_time {

   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
 	     $year += 1900;
 	     $mon  += 1;
 	   
 	   if($mon<10){  $mon="0".$mon;   }
 	   if($mday<10){ $mday="0".$mday; }
 	    
   my $CDate = $mon."\/".$mday; 

   return $CDate; 
}


1;
