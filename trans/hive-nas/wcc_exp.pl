#!/usr/bin/perl
use strict;
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
   
   $year  += 1900;
   $mon    = sprintf("%02d", $mon + 1);
   $mday   = sprintf("%02d", $mday);
   my $TODAY  = "${year}${mon}${mday}";
#my $tx__dt = substr(${CONTROL__FILE},length(${CONTROL__FILE})-12, 8);
my $tx__dt=calculateTxDate($TODAY,1);
print "${tx__dt}=========================\n";
my $sql__str="use ods;
   set hive.exec.dynamic.partition.mode=nonstrict;
   insert overwrite table wx__user__contract__info partition(data__dt) 
   SELECT  
T3.Id WX__USER__ID -- 微信用户ID
, concat(T3.Id,COALESCE(T5.CONTRACTNO,'')) ID
,COALESCE(T8.Brcname,T9.BRCNAME,T10.BRCNAME,'')  BRC__NAME
,T5.CHANNETIME CHANNNE__TIME
,T5.ISSUETIME REQ__LEND__TIME
,T5.ISSUEAMT    ISSUE__AMT  
,T5.CONTRACTAMT CONTRACT__AMT
,'' PRODUCT__VER__NAME
,COALESCE(T7.CITYNAME,'') CITY__NAME 
,day(T5.CONTBEGINDATE) REPAY__DAY
,CASE WHEN T5.CONSTATUS in ('9','12','13','14','15') THEN 1 WHEN T5.CONSTATUS is NULL THEN ''  ELSE 0 END IS__SETTLED
, from__unixtime(unix__timestamp()) CREATE__TIME 
,''TARGET__TYPE
,''TEMPLATE__NO
,''SYSTEM__NO
,'' SERIAL__NUMBER
,'' MESSAGE__KEYWORDS
,COALESCE(T4.public__user__id,'') PUBLIC__USER__ID --公众号id
,COALESCE(T5.CONTRACTNO,'') CONTRACTNO --合同号
,'0' YN --有效
,COALESCE(T3.OPEN__ID,'') WX__USER__OPEN__ID  --openid
,T6.productvername PRODUCT__CLASS
,$tx__dt 
FROM  (select Fans__Id,Customer__No,Data__Dt ,row__number() OVER (PARTITION BY Customer__No ORDER BY Create__Time desc) as rank1
FROM WCC__YX__CUSTOMER__S  WHERE Data__Dt=${tx__dt})T1
LEFT JOIN ODS.WCC__YX__FANS__S T2
ON T1.Fans__Id = T2.Id
AND T1.Data__Dt=T2.Data__Dt
And T1.rank1=1
LEFT JOIN WCC__WX__USER__S T3
ON T3.Id = T2.Wx__User__Id
AND T3.Data__Dt=T2.Data__Dt
LEFT JOIN WCC__WX__NORMAL__USER__S T4
ON T3.Id =  T4.Id
AND T3.Data__Dt=T4.Data__Dt
LEFT JOIN COR__LNSCONTRACTINFO__S T5
ON T1.CUSTOMER__NO=T5.CUSTOMERID
AND T1.Data__Dt=T5.Data__Dt
LEFT JOIN COR__PUBPRODUCTCLASS__S T6
ON T5.PRODUCTCLASS=T6.Vproducttypeno
AND T5.Data__Dt=T6.Data__Dt
LEFT JOIN COR__PUBCITYCODEINFO__S  T7
ON T5.CITY=T7.CITYCODE
AND T5.Data__Dt=T7.Data__Dt
LEFT JOIN (select FBRCID,BRCNAME,rank() OVER (PARTITION BY FBRCID ORDER BY SYSMODDATE desc ) AS  rank1
           from COR__PUBBRANCHINFO__S 
           WHERE Data__Dt=${tx__dt} 
           )T8
ON T8.FBRCID=T5.FBRCID
AND T8.rank1=1
LEFT JOIN (select SMPBRCCODE,BRCNAME,row__number() OVER (PARTITION BY SMPBRCCODE ORDER BY SYSMODDATE desc) as rank1
           FROM COR__PUBBRANCHMAP__S   WHERE Data__Dt=${tx__dt} 
) T9 
ON T5.SMPBRCCODE=T9.SMPBRCCODE
AND T9.rank1=1
LEFT JOIN (select UCBRCCODE,BRCNAME,row__number() OVER (PARTITION BY UCBRCCODE ORDER BY SYSMODDATE desc) as rank1
           FROM COR__PUBBRANCHMAP__S   WHERE Data__Dt=${tx__dt} 
 ) T10 
ON T5.UCBRCCODE=T10.UCBRCCODE
AND T10.rank1=1
WHERE T1.Data__Dt=${tx__dt} AND T3.ID IS NOT NULL AND T5.CONTRACTNO IS NOT NULL;
";
my $ret = exe__hive__sql($sql__str);

sub calculateTxDate
{
   my ($txdate, $period) = @__;
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

sub exe__hive__sql{
              my ($hive__sql) = @__;
              $hive__sql = qq{"$hive__sql"};
              my $hive__cmd = "hive -v -e $hive__sql";
              my $ret=system("$hive__cmd");
              if($ret!=0){
                  print "hql run failed!\n";
                  return 1;
              }
              return 0;
          }

if($ret==0){
   `python /bin/hive2localfile__exportor.py  /data/hive__tmp $tx__dt  wcc wx__user__contract__info  "select * from ods.wx__user__contract__info where data__dt=%s"`;
    my $exp__flag = $?;
    if($exp__flag!=0){
         $ret=1;
         exit(1);
    } 
   
         my $scp__cmd="python /etl/bin/scp__utils.py 0.0.0.0 2222 username password /wcc__BI/BI__DATAFILES/$tx__dt /data/hive__tmp/$tx__dt/wcc";
          
          my $scp__flag =system($scp__cmd);
          if($scp__flag!=0){
         $ret=1;
         exit(1);
    } 
       
}
print $ret."=================$tx__dt=============\n";
exit($ret);
