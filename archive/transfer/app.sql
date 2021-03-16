insert overwrite table app.wx__user__contract__info partition (data__date=$data__date)
SELECT T3.Id WX__USER__ID ,
       -- 微信用户ID
       concat(T3.Id, COALESCE(T5.CONTRACTNO, '')) ID,
       COALESCE(T8.Brcname, T9.BRCNAME, T10.BRCNAME, '') BRC__NAME,
       T5.CHANNETIME CHANNNE__TIME,
       T5.ISSUETIME REQ__LEND__TIME,
       T5.ISSUEAMT ISSUE__AMT,
       T5.CONTRACTAMT CONTRACT__AMT,
       '' PRODUCT__VER__NAME,
       COALESCE(T7.CITYNAME, '') CITY__NAME,
       day(T5.CONTBEGINDATE) REPAY__DAY,
       CASE
         WHEN T5.CONSTATUS in ('9', '12', '13', '14', '15') THEN
          1
         WHEN T5.CONSTATUS is NULL THEN
          ''
         ELSE
          0
       END IS__SETTLED,
       from__unixtime(UNIX__TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') CREATE__TIME,
       '' TARGET__TYPE,
       '' TEMPLATE__NO,
       '' SYSTEM__NO,
       '' SERIAL__NUMBER,
       '' MESSAGE__KEYWORDS,
       COALESCE(T4.public__user__id, '') PUBLIC__USER__ID --公众号id
      ,
       COALESCE(T5.CONTRACTNO, '') CONTRACTNO --合同号
      ,
       '0' YN --有效
      ,
       COALESCE(T3.OPEN__ID, '') WX__USER__OPEN__ID --openid
      ,
       T6.productvername PRODUCT__CLASS

FROM (select Fans__Id,
               Customer__No,
               row__number() OVER(PARTITION BY Customer__No ORDER BY Create__Time desc) as rank1
          FROM ods.wcc__yx__customer) T1
  LEFT JOIN ods.wcc__yx__fans T2
    ON T1.Fans__Id = T2.Id
   And T1.rank1 = 1
  LEFT JOIN ods.wcc__wx__user T3
    ON T3.Id = T2.Wx__User__Id
  LEFT JOIN ods.wcc__wx__normal__user T4
    ON T3.Id = T4.Id
  LEFT JOIN ods.tcsv__lnscontractinfo T5
    ON T1.CUSTOMER__NO = T5.CUSTOMERID
  LEFT JOIN ods.tcsv__pubproductclass T6
    ON T5.PRODUCTCLASS = T6.Vproducttypeno
  LEFT JOIN ods.tcsv__pubcitycodeinfo T7
    ON T5.CITY = T7.CITYCODE
  LEFT JOIN (select FBRCID,
                    BRCNAME,
                    rank() OVER(PARTITION BY FBRCID ORDER BY SYSMODDATE desc) AS rank1
               from ods.tcsv__pubbranchinfo) T8
    ON T8.FBRCID = T5.FBRCID
   AND T8.rank1 = 1
  LEFT JOIN (select SMPBRCCODE,
                    BRCNAME,
                    row__number() OVER(PARTITION BY SMPBRCCODE ORDER BY SYSMODDATE desc) as rank1
               FROM ods.tcsv__pubbranchmap) T9
    ON T5.SMPBRCCODE = T9.SMPBRCCODE
   AND T9.rank1 = 1
  LEFT JOIN (select UCBRCCODE,
                    BRCNAME,
                    row__number() OVER(PARTITION BY UCBRCCODE ORDER BY SYSMODDATE desc) as rank1
               FROM ods.tcsv__pubbranchmap) T10
    ON T5.UCBRCCODE = T10.UCBRCCODE
   AND T10.rank1 = 1
 WHERE T3.ID IS NOT NULL
   AND T5.CONTRACTNO IS NOT NULL;

