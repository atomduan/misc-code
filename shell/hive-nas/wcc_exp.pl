#!/usr/bin/perl
use strict;
#unshift(@INC, "$ENV{AUTO_HOME}/bin");
#require etl_util;
#my $CONTROL_FILE = $ARGV[0];
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
   
   $year  += 1900;
   $mon    = sprintf("%02d", $mon + 1);
   $mday   = sprintf("%02d", $mday);
   my $TODAY  = "${year}${mon}${mday}";
#my $tx_dt = substr(${CONTROL_FILE},length(${CONTROL_FILE})-12, 8);
my $tx_dt=calculateTxDate($TODAY,1);
print "${tx_dt}=========================\n";
my $sql_str="use ods;
   set hive.exec.dynamic.partition.mode=nonstrict;
   insert overwrite table user_contract_info partition(data_dt) 
   SELECT  
T3.Id USER_ID 
, concat(T3.Id,COALESCE(T5.CONTRACTNO,'')) ID
,COALESCE(T8.Brcname,T9.BRCNAME,T10.BRCNAME,'')  BRC_NAME
,T5.CHANNETIME CHANNNE_TIME
,T5.ISSUETIME REQ_LEND_TIME
,T5.ISSUEAMT    ISSUE_AMT  
,T5.CONTRACTAMT CONTRACT_AMT
,'' PRODUCT_VER_NAME
,COALESCE(T7.CITYNAME,'') CITY_NAME 
,day(T5.CONTBEGINDATE) REPAY_DAY
,CASE WHEN T5.CONSTATUS in ('9','12','13','14','15') THEN 1 WHEN T5.CONSTATUS is NULL THEN ''  ELSE 0 END IS_SETTLED
, from_unixtime(unix_timestamp()) CREATE_TIME 
,''TARGET_TYPE
,''TEMPLATE_NO
,''SYSTEM_NO
,'' SERIAL_NUMBER
,'' MESSAGE_KEYWORDS
,COALESCE(T4.public_user_id,'') PUBLIC_USER_ID 
,COALESCE(T5.CONTRACTNO,'') CONTRACTNO 
,'0' YN --ÓÐÐ§
,COALESCE(T3.OPEN_ID,'') USER_OPEN_ID  
,T6.productvername PRODUCT_CLASS
,$tx_dt 
FROM  (select Fans_Id,Customer_No,Data_Dt ,row_number() OVER (PARTITION BY Customer_No ORDER BY Create_Time desc) as rank1
FROM WCC_CUSTOMER_S  WHERE Data_Dt=${tx_dt})T1
LEFT JOIN ODS.WCC_FANS_S T2
ON T1.Fans_Id = T2.Id
AND T1.Data_Dt=T2.Data_Dt
And T1.rank1=1
LEFT JOIN WCC_USER_S T3
ON T3.Id = T2.User_Id
AND T3.Data_Dt=T2.Data_Dt
LEFT JOIN WCC_NORMAL_USER_S T4
ON T3.Id =  T4.Id
AND T3.Data_Dt=T4.Data_Dt
LEFT JOIN COR_LNSCONTRACTINFO_S T5
ON T1.CUSTOMER_NO=T5.CUSTOMERID
AND T1.Data_Dt=T5.Data_Dt
LEFT JOIN COR_PUBPRODUCTCLASS_S T6
ON T5.PRODUCTCLASS=T6.Vproducttypeno
AND T5.Data_Dt=T6.Data_Dt
LEFT JOIN COR_PUBCITYCODEINFO_S  T7
ON T5.CITY=T7.CITYCODE
AND T5.Data_Dt=T7.Data_Dt
LEFT JOIN (select FBRCID,BRCNAME,rank() OVER (PARTITION BY FBRCID ORDER BY SYSMODDATE desc ) AS  rank1
           from COR_PUBBRANCHINFO_S 
           WHERE Data_Dt=${tx_dt} 
           )T8
ON T8.FBRCID=T5.FBRCID
AND T8.rank1=1
LEFT JOIN (select SMPBRCCODE,BRCNAME,row_number() OVER (PARTITION BY SMPBRCCODE ORDER BY SYSMODDATE desc) as rank1
           FROM COR_PUBBRANCHMAP_S   WHERE Data_Dt=${tx_dt} 
) T9 
ON T5.SMPBRCCODE=T9.SMPBRCCODE
AND T9.rank1=1
LEFT JOIN (select UCBRCCODE,BRCNAME,row_number() OVER (PARTITION BY UCBRCCODE ORDER BY SYSMODDATE desc) as rank1
           FROM COR_PUBBRANCHMAP_S   WHERE Data_Dt=${tx_dt} 
 ) T10 
ON T5.UCBRCCODE=T10.UCBRCCODE
AND T10.rank1=1
WHERE T1.Data_Dt=${tx_dt} AND T3.ID IS NOT NULL AND T5.CONTRACTNO IS NOT NULL;
";
my $ret = exe_hive_sql($sql_str);

sub calculateTxDate
{
   my ($txdate, $period) = @_;
   my ($year, $month, $day);
   
   if ($period == 0) { return $txdate; }
   
   $year  = substr($txdate, 0, 4);
   $month = substr($txdate, 4, 2);
   $day   = substr($txdate, 6, 2);

   # Convert string to number in order to cut the prefix zero
   $year += 0;
   $month += 0;
   $day += 0;

   while ($period > 0) {
      if ($day == 1) {
      	$month--;
      	if ($month==0) {
      	   $year--;
      	   $month = 12;
      	}
      	if ($month==1||$month==3||$month==5||$month==7||$month==8||
      	    $month==10||$month==12) {
            $day = 31;      	    	
      	}
      	elsif ($month==4||$month==6||$month==9||$month==11) {
      	    $day = 30;
      	}
      	elsif ($month==2 && ((($year%4)==0 && ($year%100)!=0) || ($year%400)==0)) {
      	    $day = 29;
      	}
      	elsif ($month==2) {
      	    $day = 28;
      	}
      } else {
      	$day--;
      }
      
      $period--;
   }

   if ($month < 10 && substr($month, 0, 1) ne "0") {
      $month = "0${month}";
   }

   if ($day < 10 && substr($day, 0, 1) ne "0") {
      $day = "0${day}";
   }
   
   $txdate = "${year}${month}${day}";   

   return $txdate;
}


# Get the current moment, by year, month, day, hour, minute
sub getNow
{
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
   my $current = "";
   
   $year += 1900;
   $mon   = $mon + 1;
   
   return ($year, $mon, $mday, $wday, $hour, $min);
}
#my $ret=0;

sub exe_hive_sql{
              my ($hive_sql) = @_;
              $hive_sql = qq{"$hive_sql"};
              my $hive_cmd = "hive -v -e $hive_sql";
              my $ret=system("$hive_cmd");
              if($ret!=0){
                  print "hql run failed!\n";
                  return 1;
              }
              return 0;
          }

if($ret==0){
   `python /path/to/this/file/hive2localfile_exportor.py  /data/hive_tmp $tx_dt  wcc user_contract_info  "select * from ods.user_contract_info where data_dt=%s"`;
    my $exp_flag = $?;
    if($exp_flag!=0){
         $ret=1;
         print "\n";
         exit(1);
    } 
   
         my $scp_cmd="python /path/to/this/file/scp_utils.py 10.120.64.55 2222 yourdb yourpasswd /path/to/this/database";
         print  $scp_cmd."+++++++++++++++++++++++++++++++++\n";
          
          my $scp_flag =system($scp_cmd);
        print $scp_flag."+++++++++++++++++++++++++++++++++\n";
          if($scp_flag!=0){
         $ret=1;
         print "-----\n";
         exit(1);
    } 
       
}
print $ret."=================$tx_dt=============\n";
exit($ret);
