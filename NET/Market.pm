#!/usr/bin/perl


package NET::Market;

use LWP::UserAgent;
use Data::Dumper;
use strict;
use Switch; 

# example Web connect inf
# http://justdata.yuanta.com.tw/z/zg/zg_FA_0_30.djhtm

# External 外資買賣超
$GbWebInfExternalBuyer  ="http://justdata.yuanta.com.tw/z/zg/zg_D_0_";
$GbWebInfExternalSeller ="http://justdata.yuanta.com.tw/z/zg/zg_DA_0_";
$GbWebInf =".djhtm";

# Internal 投信買賣超
$GbWebInfInternalBuyer  ="http://justdata.yuanta.com.tw/z/zg/zg_DD_0_";
$GbWebInfInternalSeller ="http://justdata.yuanta.com.tw/z/zg/zg_DE_0_";

# self 自營商買賣超
$GbWebInfSelfBuyer      ="http://justdata.yuanta.com.tw/z/zg/zg_DB_0_";
$GbWebInfSelfSeller     ="http://justdata.yuanta.com.tw/z/zg/zg_DC_0_";

#main 主力買賣超
$GbWebInfMainBuyer  ="http://justdata.yuanta.com.tw/z/zg/zg_F_0_";
$GbWebInfMainSeller ="http://justdata.yuanta.com.tw/z/zg/zg_FA_0_";

# http://justdata.yuanta.com.tw/z/zg/zgb/zgb0_5650_5.djhtm
$GbWebStTder ="http://justdata.yuanta.com.tw/z/zg/zgb/zgb0_";


sub new {
my $self = shift;

return bless {};	
}

sub GetHTMLBuyerAndSellerInfOffLine{
	
	my ($iMyHTML,$iMyTradeDate,$iMyMtHashPtr,$iMyCase,$iMySel) = (@_);
	
	my $MyHTML      = ${$iMyHTML};
	my $MyTradeDate = ${$iMyTradeDate};
	my %MyMtHashPtr = %{$iMyMtHashPtr};
    my $MyCase      = ${$iMyCase};
    my $MySel       = ${$iMySel};
    
    my $MyStockID ={};
    my $MuStockNm ={};
    my $MyCotID ={}; 
    my $MyTmpPtr ={};
    my $MyDiff ={};
    my $MyClose ={};
    my $MyTicketCot={};
    my $MyRecord={};
    
    my @MyStPtr = split("\n",$MyHTML);
    
    $MyCotID =0;
    $MyRecord =1;
    
    foreach(@MyStPtr){
    	#print $_."\n";
    	    s/\,//g;
    	    
    	 if(/^\s+GenLink2stk\(\'(\S+)\'\'(\S+)\'\)\;/){   $MyStockID=$1; $MuStockNm=$2; 	 }
      elsif(/^\<td class=\"[a-z0-9]*\"\>[+]*\&[a-z]*\;(\S+)(\%)*\<\/td\>/){ $MyTmpPtr=$1; ++$MyCotID; }
      else{}
      
       
        if($MyCotID==1){ $MyClose     = $MyTmpPtr; }
     elsif($MyCotID==2){ $MyDiff      = $MyTmpPtr; } 
     elsif($MyCotID==3){ $MyDiffPer   = $MyTmpPtr; }
     elsif($MyCotID==4){ $MyTicketCot = $MyTmpPtr; }
     elsif($MyCotID==5){ }
     elsif($MyCotID==6){ $MyTicketCot = $MyTmpPtr; }
    
    if( ($MySel==0 && $MyCotID==4) ||
        ($MySel!=0 && $MyCotID==6) ){
        	       	                                 
    $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRecord} = {
	           	  "STID"   => "$MyStockID",
	           	  "STNAME" => "$MuStockNm",
	           	  "CLOSE"  => "$MyClose",
	           	  "DIFF"   => "$MyDiff",
	           	  "DIFFPER"=> "$MyDiffPer",
	           	  "COUNT"  => "$MyTicketCot",
     	      }; 
	           
	           $MyRecord++;
	           $MyCotID=0;
       }
    }
   
 #DisplayMarketBuyerAndSellerInfOffLine(\%MyMtHashPtr,\$MyTradeDate,\"0");  
 #exit; 
return \%MyMtHashPtr;
}

sub ExportMarketBuyerAndSellerInfOffLine{
	    my $self = shift;

		my ($iMyPeriod,$iMyTradeDate,$iMyCase,$iMyMtHashPtr,$iMySel) = (@_);
       
        my %MyMtHashPtr = %{$iMyMtHashPtr};
        my $MyTradeDate = ${$iMyTradeDate};
        my $MyCase      = ${$iMyCase};
        my $MyPeriod    = ${$iMyPeriod};
        my $MySel       = ${$iMySel};
        
        my $MyRank ={};
        my $MyStockID ={};
        my $MySTNAME  ={};
        my $MyClose   ={};
        my $MyDiff    ={};
        my $MyDiffPer ={};
        my $MyCount   ={};
        my $MyOutFilePtr ={};
        
        if($MyCase==0){ 
        	 if($MySel==0){ $MyOutFilePtr = "../../data_off/external/super_buy_$MyPeriod"; }
          elsif($MySel==1){ $MyOutFilePtr = "../../data_off/internal/super_buy_$MyPeriod"; }
          elsif($MySel==2){ $MyOutFilePtr = "../../data_off/self/super_buy_$MyPeriod";     }
          elsif($MySel==3){ $MyOutFilePtr = "../../data_off/main/super_buy_$MyPeriod";     }
          	 
        }elsif($MyCase==1){          
        	if($MySel==0){  $MyOutFilePtr = "../../data_off/external/super_sell_$MyPeriod"; }
         elsif($MySel==1){  $MyOutFilePtr = "../../data_off/internal/super_sell_$MyPeriod"; }
         elsif($MySel==2){  $MyOutFilePtr = "../../data_off/self/super_sell_$MyPeriod";     }
         elsif($MySel==3){  $MyOutFilePtr = "../../data_off/main/super_sell_$MyPeriod";     }
        }
        
        $MyTradeDate =~ s/\//\_/g;
         
        $MyOutFilePtr = $MyOutFilePtr."/$MyTradeDate.csv";
        open(oFilePtr, ">$MyOutFilePtr") or die "$!\n";
        
        foreach(sort keys %MyMtHashPtr){
          $MyTradeDate = $_;
    
          foreach(sort {$a<=>$b} keys  %{$MyMtHashPtr{$MyTradeDate}{$MyCase}} ){
               $MyRank = $_;
         
               $MyStockID = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"STID"};
               $MySTNAME  = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"STNAME"};
               $MyClose   = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"CLOSE"};
               $MyDiff    = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"DIFF"};
               $MyDiffPer = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"DIFFPER"};
               $MyCount   = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"COUNT"};
               $MyStockID =~ s/AS//g;
               printf oFilePtr "$MyRank,$MyStockID,$MySTNAME,$MyClose,$MyDiff,$MyDiffPer,$MyCount\n";
          }
        }
        
}

sub DisplayMarketBuyerAndSellerInfOffLine{
#	    my $self = shift;
		my ($iMyMtHashPtr,$iMyTradeDate,$iMyCase) = (@_);
       
        my %MyMtHashPtr = %{$iMyMtHashPtr};
        my $MyTradeDate = ${$iMyTradeDate};
        my $MyCase      = ${$iMyCase};
        
        my $MyRank ={};
        my $MyStockID ={};
        my $MySTNAME  ={};
        my $MyClose   ={};
        my $MyDiff    ={};
        my $MyDiffPer ={};
        my $MyCount   ={};
        
        if($MyCase==0){
           print "Super Buy List...\n";
        }else{
           print "Super Sell List...\n";
        }
        
        foreach(sort keys %MyMtHashPtr){
          $MyTradeDate = $_;
          print $_."\n";
    
          foreach(sort {$a<=>$b} keys  %{$MyMtHashPtr{$MyTradeDate}{$MyCase}} ){
               $MyRank = $_;
         
               $MyStockID = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"STID"};
               $MySTNAME  = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"STNAME"};
               $MyClose   = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"CLOSE"};
               $MyDiff    = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"DIFF"};
               $MyDiffPer = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"DIFFPER"};
               $MyCount   = $MyMtHashPtr{$MyTradeDate}{$MyCase}{$MyRank}{"COUNT"};
               $MyStockID =~ s/AS//g;
               print "$MyRank,$MyStockID,$MySTNAME,$MyClose,$MyDiff,$MyDiffPer,$MyCount\n";
          }
        }
        
}

sub GetMarketInfSuperBuyerAnsSellerOffLine{
	my $self = shift;
	my ($iMyDay,$iMyTradeDate,$iMyCase,$iMyMtHashPtr,$iMySel) = (@_);
	my $MyDay       = ${$iMyDay};
	my $MyTradeDate = ${$iMyTradeDate};
	my $MyCase      = ${$iMyCase};
	my %MyMtHashPtr = %{$iMyMtHashPtr};
	my $MySel       = ${$iMySel};
	
	$MyMtHashPtr = GetMarketInfBuyerAndSellerOffLine(\$MyDay,\$MyTradeDate,\$MyCase,\%MyMtHashPtr,\$MySel);
	%MyMtHashPtr = %{$MyMtHashPtr};
	
	# DisplayMarketBuyerAndSellerInfOffLine(\%MyMtHashPtr,\$MyTradeDate,\"0");  
	return \%MyMtHashPtr;
}

sub GetMarketInfBuyerAndSellerOffLine{
#   my $self = shift;
   
   my ($iMyDay,$iMyTradeDate,$iMyCase,$iMyMtHashPtr,$iMySel) = (@_);
   
   my $MyDay       = ${$iMyDay};
   my $MyTradeDate = ${$iMyTradeDate};
   my %MyMtHashPtr = %{$iMyMtHashPtr};
   my $MyCase      = ${$iMyCase};
   my $MySel       = ${$iMySel};
   	
   my $MyWebInf    ={};
   my $MyHTMLPtr   ={};
   
 # Create a user agent object
  use LWP::UserAgent;
  $ua = LWP::UserAgent->new;
  $ua->agent("MyApp/0.1");
  
  if($MyCase==0){
  	   if($MySel==0){ $MyWebInf = $GbWebInfExternalBuyer.$MyDay.$GbWebInf; }
  	elsif($MySel==1){ $MyWebInf = $GbWebInfInternalBuyer.$MyDay.$GbWebInf; }
  	elsif($MySel==2){ $MyWebInf = $GbWebInfSelfBuyer.$MyDay.$GbWebInf;     }
  	elsif($MySel==3){ $MyWebInf = $GbWebInfMainBuyer.$MyDay.$GbWebInf;     }
  
  }elsif($MyCase==1){
  	  if($MySel==0){  $MyWebInf = $GbWebInfExternalSeller.$MyDay.$GbWebInf;}
   elsif($MySel==1){  $MyWebInf = $GbWebInfInternalSeller.$MyDay.$GbWebInf;}
   elsif($MySel==2){  $MyWebInf = $GbWebInfSelfSeller.$MyDay.$GbWebInf;    }
   elsif($MySel==3){  $MyWebInf = $GbWebInfMainSeller.$MyDay.$GbWebInf;    }	  
  }
  
  # Create a request
  my $req = HTTP::Request->new(GET => $MyWebInf);
  #$req->content_type('application/x-www-form-urlencoded');
  #$req->content('query=libwww-perl&mode=dist');

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
       $MyHTMLPtr = $res->content;
       #print $MyHTMLPtr;
       $MyMtHashPtr = GetHTMLBuyerAndSellerInfOffLine(\$MyHTMLPtr,\$MyTradeDate,\%MyMtHashPtr,\$MyCase,\$MySel);
       %MyMtHashPtr = %{$MyMtHashPtr};
  }
  else {
      print $res->status_line, "\n";
  }
  
  return \%MyMtHashPtr;
}

sub GetEachStockTraderRelaton{
	
	my ($iMyMtHashPtr,$iMyStTdHashPtr,$iMyMtCase,$iMyTdCase,$iMyTraderID) =(@_);
	my %MyMtHashPtr   = %{$iMyMtHashPtr};
	my %MyStTdHashPtr = %{$iMyStTdHashPtr};
	my $MyMtCase      = ${$iMyMtCase};
	my $MyTdCase      = ${$iMyTdCase};
	my $MyTraderID    = ${$iMyTraderID};
	my $MyPeriod =1;
	
	my ($MyRank,$MyStockID,$MySTNAME,$MyClose,$MyDiff,$MyDiffPer,$MyCount) = {};
    my ($MySTID,$MySTNM,$MyByCot,$MySeCot,$MyToCot) ={};
    
    #DisplayEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"0",\%MyStTdHashPtr);
    #DisplayMarketBuyerAndSellerInfOffLine(\$MyTradeDate,\"0");
    #exit;
    foreach(sort keys %MyMtHashPtr){
          $MyTradeDate = $_;
          foreach(sort {$a<=>$b} keys  %{$MyMtHashPtr{$MyTradeDate}{$MyMtCase}} ){
               $MyRank = $_;      
               $MyStockID = $MyMtHashPtr{$MyTradeDate}{$MyMtCase}{$MyRank}{"STID"};
               $MySTNAME  = $MyMtHashPtr{$MyTradeDate}{$MyMtCase}{$MyRank}{"STNAME"};
               $MyClose   = $MyMtHashPtr{$MyTradeDate}{$MyMtCase}{$MyRank}{"CLOSE"};
               $MyDiff    = $MyMtHashPtr{$MyTradeDate}{$MyMtCase}{$MyRank}{"DIFF"};
               $MyDiffPer = $MyMtHashPtr{$MyTradeDate}{$MyMtCase}{$MyRank}{"DIFFPER"};
               $MyCount   = $MyMtHashPtr{$MyTradeDate}{$MyMtCase}{$MyRank}{"COUNT"};
               $MyStockID =~ s/AS//g;
               $MyCount   =~ s/\,//g;
               
               #DisplayEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"0",\%MyStTdHashPtr);
               
               foreach( sort {$a<=>$b} keys %{$MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyTdCase}} ){
	  	        $MyRank  = $_;
	          	$MySTID  = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyTdCase}{$MyRank}{"STID"};
	  	        $MySTNM  = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyTdCase}{$MyRank}{"STNM"};
	           	$MyByCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyTdCase}{$MyRank}{"BYCOT"};
	  	        $MySeCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyTdCase}{$MyRank}{"SLCOT"};
	  	        $MyToCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyTdCase}{$MyRank}{"TOCOT"};
	  	        
	  	        if($MyStockID eq $MySTID){
	  	        	print "TraderID:: $MyTraderID\n";
	  	        	print "  Buy  -> $MySTNM($MySTID):: $MyByCot\n";
	  	        	print "  Sell -> $MySTNM($MySTID):: $MySeCot\n";
	  	        }
              }
        }
    }
}

sub GetTraderBuyerInf4SuperBuyDay{}
sub GetTraderSellerInf4SuperSellDay{}
sub GetTraderSellerInf4SuperBuyDay{}

sub ExportTraderInf2Local{
    my $self = shift;
	my ($iMyTradeDate,$iMyDay,$iMyPeriod) = (@_);
	my $MyTradeDate = ${$iMyTradeDate};
	my $MyDay       = ${$iMyDay};
	my $MyPeriod    = ${$iMyPeriod};
    my $MyTraderID  ={};
	my $MyOutFilePtr ={};
	
	TsExternalStockTrader2Index();
	TsInternalBankTrader2Index();
	TsInternalStockTrader2Index();
	
	my @IntBkArrListPtr   = values(%IntBkTdHashPtr);
	my @ExtStTdArrListPtr = values(%ExtStTdHashPtr);
	my @IntStTdArrListPtr = values(%IntStTdHashPtr);
	
	$MyTradeDate =~ s/\//\_/g;
	
	 #update the TradeDateList.txt
	  
     $MyOutFilePtr =  "../../data_off/trader/TradeDateList.csv"; 
     open(oFilePtr, ">>$MyOutFilePtr") or die "$!\n";
	 printf oFilePtr "$MyTradeDate\n";
	
	#find the Internal Bank lists for "Buy/Sell"
	$MyOutFilePtr ="../../data_off/trader/internal_bank/buy/$MyTradeDate";
	 mkdir("$MyOutFilePtr", 0777) || print $!;	 
	$MyOutFilePtr ="../../data_off/trader/internal_bank/sell/$MyTradeDate";
	 mkdir("$MyOutFilePtr", 0777) || print $!;
	  
	print "Export Internal Bank lists...\n";
	foreach(@IntBkArrListPtr){
	  $MyTraderID = $_;
	  $MyTdHashPtr = GetEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\%MyTdHashPtr);
	  %MyTdHashPtr = %{$MyTdHashPtr};
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"0",\$MyTradeDate,\"internal_bank",\%MyTdHashPtr); 
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"1",\$MyTradeDate,\"internal_bank",\%MyTdHashPtr);
	}
	
	#find the Internal stock lists for "Buy/Sell"
	$MyOutFilePtr ="../../data_off/trader/internal_stock/buy/$MyTradeDate";
	 mkdir("$MyOutFilePtr", 0777) || print $!;	 
	$MyOutFilePtr ="../../data_off/trader/internal_stock/sell/$MyTradeDate";
	 mkdir("$MyOutFilePtr", 0777) || print $!;
	
	print "Export Internal Stock lists...\n";
	foreach(@IntStTdArrListPtr){
	  $MyTraderID = $_;
	  $MyTdHashPtr = GetEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\%MyTdHashPtr);
	  %MyTdHashPtr = %{$MyTdHashPtr};
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"0",\$MyTradeDate,\"internal_stock",\%MyTdHashPtr); 
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"1",\$MyTradeDate,\"internal_stock",\%MyTdHashPtr);
	}
	 
	#find the external stock list for "Buy/Sell"
	$MyOutFilePtr ="../../data_off/trader/external_stock/buy/$MyTradeDate";
	 mkdir("$MyOutFilePtr", 0777) || print $!;	 
	$MyOutFilePtr ="../../data_off/trader/external_stock/sell/$MyTradeDate";
	 mkdir("$MyOutFilePtr", 0777) || print $!;
	
	print "Export external Stock lists...\n";
	foreach(@ExtStTdArrListPtr){
	  $MyTraderID = $_;
	  $MyTdHashPtr = GetEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\%MyTdHashPtr);
	  %MyTdHashPtr = %{$MyTdHashPtr};
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"0",\$MyTradeDate,\"external_stock",\%MyTdHashPtr); 
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"1",\$MyTradeDate,\"external_stock",\%MyTdHashPtr);
	} 
	
}

sub GetTraderBuyerInf4SuperSellDay{
	my $self = shift;
	my ($iMyTradeDate,$iMyDay,$iMyPeriod) = (@_);
	my $MyTradeDate = ${$iMyTradeDate};
	my $MyDay       = ${$iMyDay};
	my $MyPeriod    = ${$iMyPeriod};
	
	my $MyTraderID  ={};
	
	TsExternalStockTrader2Index();
	TsInternalBankTrader2Index();
	TsInternalStockTrader2Index();
	
	my @IntBkArrListPtr   = values(%IntBkTdHashPtr);
	my @ExtStTdArrListPtr = values(%ExtStTdHashPtr);
	my @IntStTdArrListPtr = values(%IntStTdHashPtr);
	
	my %MyMtHashPtr =();
	my %MyTdHashPtr =();
	
	print "Get the Markt super Buy/Sell Lists ...\n";
    $MyMtHashPtr = GetMarketInfBuyerAndSellerOffLine(\$MyDay,\$MyTradeDate,\"1",\%MyMtHashPtr);
    %MyMtHashPtr = %{$MyMtHashPtr};
	#DisplayMarketBuyerAndSellerInfOffLine(\%MyMtHashPtr,\$MyTradeDate,\"1");
	 
	#find the Internal Bank lists for "Buy"
	print "Check Internal Bank lists...\n";
	foreach(@IntBkArrListPtr){
	  $MyTraderID = $_;	
	  $MyTdHashPtr = GetEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\%MyTdHashPtr);
	  %MyTdHashPtr = %{$MyTdHashPtr};
	  GetEachStockTraderRelaton(\%MyMtHashPtr,\%MyTdHashPtr,\"1",\"0",\$MyTraderID);
	  ExportEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"0",\$MyTradeDate,\"internal_bank",\%MyTdHashPtr); 
	}
		        
	 
	  
	#find the External Trader lists for "Buy"
	print "Check External Trader lists...\n";
    foreach(@ExtStTdArrListPtr){
      $MyTraderID = $_;		
      $MyTdHashPtr = GetEachStockTraderInfOffLine(\$_,\$MyPeriod,\%MyTdHashPtr);
      %MyTdHashPtr = %{$MyTdHashPtr};
      GetEachStockTraderRelaton(\%MyMtHashPtr,\%MyTdHashPtr,\"1",\"0",\$MyTraderID);	
    }
    
    #find the Internal trader lists for "Buy"
    print "Check Internal Trader lists...\n";
    foreach(@IntStTdArrListPtr){
     $MyTraderID = $_;		
     $MyTdHashPtr = GetEachStockTraderInfOffLine(\$_,\$MyPeriod,\%MyTdHashPtr);
     %MyTdHashPtr = %{$MyTdHashPtr};
     GetEachStockTraderRelaton(\%MyMtHashPtr,\%MyTdHashPtr,\"1",\"0",\$MyTraderID);
    }
}

sub TsExternalStockTrader2Index{
	
	 %ExtStTdHashPtr = (
	  "友邦證卷"           => "0180",
	  "台灣摩根士丹利"     => "1470",
	  "安智證券"           => "0200",
	  "法銀巴黎證卷"       => "8900",
	  "花旗(台灣)商業銀行" => "0790",
	  "花旗環球"           => "1590",
	  "美商美林"           => "1440",
	  "美商高盛"           => "1480",
	  "英商巴克萊銀行台北分行" => "0840",
	  "香港上海匯豐"       => "0800",
	  "富通證券"           => "1970",
	  "港商上海匯豐證券"   => "8960",
	  "港商里昂"          => "1380",
	  "港商法國興業"      => "1570",
	  "港商美銀證券亞洲台北分行" => "0580",
	  "港商荷銀"          => "1400",
	  "港商野村"          => "1560",
	  "港商麥格里"        => "1360",
	  "新加坡商瑞銀證券"  => "1650",
	  "瑞士信貸"         => "1520",
	  "瑞士商瑞士銀行台北分行 " => "0820",
	  "德商德意志銀行台北分公司" => "0550",
	  "德意志亞洲"        => "1530",
	  "摩根大通"          => "8440",
	  "摩根富林明"        => "0190", 
	);
	return \%ExtStTdHashPtr;
}

sub TsInternalStockTrader2Index{
	
	%IntStTdHashPtr = (
	 "(牛牛牛)亞證券" => "6010",
	 "大和國泰證券"   => "8890",
	 "大展證券"       => "5050",
	 "大眾證券"       => "6530",
	 "大華證券"       => "5720",
	 "大慶證券"       => "5260",
	 "中信銀證"       => "6160",
	 "元大證券"       => "9800",
	 "元富證券"       => "5920",
	 "太平洋證券"     => "5180",
	 "日盛證券"       => "1160",
	 "台証證券"       => "9400",
	 "台灣工銀證券"   => "1090",
	 "永豐金證券"     => "5510",
	 "玉山證券"       => "8840",
	 "兆豐證券"       => "7000",
	 "宏遠證券"       => "1260",
	 "亞東證券"       => "2180",
	 "花旗證券"       => "8700",
	 "金鼎證券"       => "5820",
	 "致和證券"       => "7030",
	 "國泰證券"       => "8880",
	 "國票證券"       => "7790",
	 "康和證券"       => "8450",
	 "第一金證券"     => "5380",
	 "統一證券"       => "5850",
	 "凱基證券"       => "5650",
	 "富邦證券"       => "9600",
	 "富隆證券"       => "5110",
	 "華南永昌證券"   => "9300",
	 "新壽證券"       => "8690",
	 "群益證券"       => "5270",
	 "鼎富證券"       => "8800",
	 "福邦證券"       => "6480",
	 "德信證券"       => "6910",
	 "豐銀證券"       => "5500",
	 "寶來證券"       => "9700",
	);
	return \%IntStTdHashPtr;
}

sub TsInternalBankTrader2Index{
	
	 %IntBkTdHashPtr = (
	   "土銀"            => "1030",
	   "中華開發工業銀行" => "0500",
	   "台中商銀"        => "6110",
	   "台北富邦商銀"    => "0740",
	   "台新商銀"        => "0620",
	   "台銀"            => "1040",
	   "台灣企銀"        => "1110",
	   "玉山商銀"        => "0680",
	   "兆豐商銀"        => "0710",
	   "合庫"            => "1020",
	   "國泰世華商銀"    => "0760",
	   "第一商銀"        => "0750",
	   "渣打商銀"        => "6640",
	   "華南商銀"        => "0630",
	   "彰銀"            => "1230",
	   "聯邦商銀"        => "8580",
	);
	return \%IntBkTdHashPtr;
}

sub GetHTMLStockTraderInfOffLine{
	  
	  my ($iMyHTMLPtr,$iMyTraderID,$iMyPeriod,$iMyStTdHashPtr) = (@_);
	  my $MyHTMLPtr  = ${$iMyHTMLPtr};
	  my $MyTraderID = ${$iMyTraderID};
	  my $MyPeriod   = ${$iMyPeriod};
	  my %MyStTdHashPtr = %{$iMyStTdHashPtr};
      
      my $MyCot =0;
      my $MyCot2=0;
      my $MyCase ={};
      my $MyStockID ={};
      my $MyStockNm ={};
      my $MyBuyCot={};
      my $MySellCot={};
      my $MyTotCot={};
      my $MyRank =2;
      
      my @MyTmArrPtr =();
      @MyTmpArrPtr = split("\n",$MyHTMLPtr);
      

      foreach(@MyTmpArrPtr){
        s/\,//g;
      	if(/\<TD class=\"[t41n3]*\" nowrap\>\<a href=\"javascript\:Link2Stk\(\'(\S+)\'\)\;\"\>(\S+)\<\/a\>\<\/TD\>/){
            $MyStockID =$1;
            $MyStockNm =$2;
            $MyStockNm =~ s/[0-9]*//g;
             
            if( ($MyCot % 2)==0 ){ $MyCase=0; }
            else{                  $MyCase=1; }
            
          $MyCot ++;		
      } elsif(/\<TD class=\"[t41n3]*\"\>(\S+)\<\/TD\>/){  $MyTmpPtr =$1; ++$MyCot2; }
     
           if($MyCot2==1){ $MyBuyCot =$MyTmpPtr; }
        elsif($MyCot2==2){ $MySellCot=$MyTmpPtr; }
        elsif($MyCot2==3){ $MyTotCot =$MyTmpPtr; 
        	
        	$MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{int($MyRank/2)} ={
        		 "STID"  => "$MyStockID",
        		 "STNM"  => "$MyStockNm",
        		 "BYCOT" => "$MyBuyCot",
        		 "SLCOT" => "$MySellCot",
        		 "TOCOT" => "$MyTotCot",
        	};
        	$MyRank++;
        	$MyCot2=0;
        }
      }

#DisplayEachStockTraderInfOffLine(\$MyTraderID,\$MyPeriod,\"1",\%MyStTdHashPtr);
#exit;
      return \%MyStTdHashPtr;

}

sub ExportEachStockTraderInfOffLine{
	  my ($iMyTraderID,$iMyPeriod,$iMyCase,$iMyTradeDate,$iMyloc,$iMyStTdHashPtr) = (@_);
	  
	  my $MyTraderID    = ${$iMyTraderID};
	  my $MyPeriod      = ${$iMyPeriod};
	  my $MyCase        = ${$iMyCase};
	  my $MyTradeDate   = ${$iMyTradeDate};
	  my $Myloc         = ${$iMyloc};
	  my %MyStTdHashPtr = %{$iMyStTdHashPtr};
	  
	  my $MyRank ={};
	  my $MySTID ={};
	  my $MySTNM ={};
	  my $MyByCot={};
	  my $MySeCot={};
	  my $MyToCot={};
	  my $MyOutFilePtr={};
	    
	    $MyTradeDate =~ s/\//\_/g;
	    
	    if($MyCase==0){ $MyOutFilePtr ="../../data_off/trader/$Myloc/buy/$MyTradeDate/";  }
	  else{             $MyOutFilePtr ="../../data_off/trader/$Myloc/sell/$MyTradeDate/"; }
	  
	 $MyOutFilePtr =  $MyOutFilePtr."$MyTraderID".".csv"; 
     open(oFilePtr, ">$MyOutFilePtr") or die "$!\n";
	  	   
	  foreach( sort {$a<=>$b} keys %{$MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}} ){
	  	$MyRank  = $_;
	  	$MySTID  = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"STID"};
	  	$MySTNM  = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"STNM"};
	  	$MyByCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"BYCOT"};
	  	$MySeCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"SLCOT"};
	  	$MyToCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"TOCOT"};
	  	printf oFilePtr "$MyRank,$MySTID,$MySTNM,$MyByCot,$MySeCot,$MyToCot\n";
	  }	
}

sub DisplayEachStockTraderInfOffLine{
	  
	  my ($iMyTraderID,$iMyPeriod,$iMyCase,$iMyStTdHashPtr) = (@_);
	  my $MyTraderID    = ${$iMyTraderID};
	  my $MyPeriod      = ${$iMyPeriod};
	  my $MyCase        = ${$iMyCase};
	  my %MyStTdHashPtr = %{$iMyStTdHashPtr};
	  
	  my $MyRank ={};
	  my $MySTID ={};
	  my $MySTNM ={};
	  my $MyByCot={};
	  my $MySeCot={};
	  my $MyToCot={};
	    
	  print "TraderID  $MyTraderID\n";
	  print "Buy/Sell  $MyCase\n";
	   
	  foreach( sort {$a<=>$b} keys %{$MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}} ){
	  	$MyRank  = $_;
	  	$MySTID  = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"STID"};
	  	$MySTNM  = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"STNM"};
	  	$MyByCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"BYCOT"};
	  	$MySeCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"SLCOT"};
	  	$MyToCot = $MyStTdHashPtr{$MyTraderID}{$MyPeriod}{$MyCase}{$MyRank}{"TOCOT"};
	  	print "$MyRank,$MySTID,$MySTNM,$MyByCot,$MySeCot,$MyToCot\n";
	  }
}

sub GetEachStockTraderInfOffLine{
  
  #my $self = shift;
  
  my ($iMyTraderID,$iMyPeriod,$iMyStTdHashPtr) = (@_);
  
  my $MyTraderID = ${$iMyTraderID};
  my $MyPeriod   = ${$iMyPeriod};
  my %MyStTdHashPtr	= %{$iMyStTdHashPtr};
  
# Create a user agent object
  $ua = LWP::UserAgent->new;
  $ua->agent("MyApp/0.1");
  
  $MyWebInf = $GbWebStTder.$MyTraderID."_".$MyPeriod.$GbWebInf;
  
  # Create a request
  my $req = HTTP::Request->new(GET => $MyWebInf);
  #$req->content_type('application/x-www-form-urlencoded');
  #$req->content('query=libwww-perl&mode=dist');

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
       $MyHTMLPtr = $res->content;
       #print $MyHTMLPtr;
       $MyStTdHashPtr = GetHTMLStockTraderInfOffLine(\$MyHTMLPtr,\$MyTraderID,\$MyPeriod,\%MyStTdHashPtr);       
       %MyStTdHashPtr = %{$MyStTdHashPtr};
  }
  else {
      print $res->status_line, "\n";
  }	
  
return \%MyStTdHashPtr;	
}
1;
