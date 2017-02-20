insert overwrite table app.wx_user_contract_info partition (data_date=$data_date)
SELECT T3.Id WX_USER_ID ,
       concat(T3.Id, COALESCE(T5.CONTRACTNO, '')) ID,
       COALESCE(T8.Brcname, T9.BRCNAME, T10.BRCNAME, '') BRC_NAME,
       T5.CHANNETIME CHANNNE_TIME,
       T5.ISSUETIME REQ_LEND_TIME,
       T5.ISSUEAMT ISSUE_AMT,
       T5.CONTRACTAMT CONTRACT_AMT,
       '' PRODUCT_VER_NAME,
       COALESCE(T7.CITYNAME, '') CITY_NAME,
       day(T5.CONTBEGINDATE) REPAY_DAY,
       CASE
         WHEN T5.CONSTATUS in ('9', '12', '13', '14', '15') THEN
          1
         WHEN T5.CONSTATUS is NULL THEN
          ''
         ELSE
          0
       END IS_SETTLED,
       from_unixtime(UNIX_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') CREATE_TIME,
       '' TARGET_TYPE,
       '' TEMPLATE_NO,
       '' SYSTEM_NO,
       '' SERIAL_NUMBER,
       '' MESSAGE_KEYWORDS,
       COALESCE(T4.public_user_id, '') PUBLIC_USER_ID 
      ,
       COALESCE(T5.CONTRACTNO, '') CONTRACTNO 
      ,
       '0' YN 
      ,
       COALESCE(T3.OPEN_ID, '') WX_USER_OPEN_ID 
      ,
       T6.productvername PRODUCT_CLASS

FROM (select Fans_Id,
               Customer_No,
               row_number() OVER(PARTITION BY Customer_No ORDER BY Create_Time desc) as rank1
          FROM ods.wcc_customer) T1
  LEFT JOIN ods.wcc_fans T2
    ON T1.Fans_Id = T2.Id
   And T1.rank1 = 1
  LEFT JOIN ods.wcc_wx_user T3
    ON T3.Id = T2.Wx_User_Id
  LEFT JOIN ods.wcc_wx_normal_user T4
    ON T3.Id = T4.Id
  LEFT JOIN ods.tcsv_lnscontractinfo T5
    ON T1.CUSTOMER_NO = T5.CUSTOMERID
  LEFT JOIN ods.tcsv_pubproductclass T6
    ON T5.PRODUCTCLASS = T6.Vproducttypeno
  LEFT JOIN ods.tcsv_pubcitycodeinfo T7
    ON T5.CITY = T7.CITYCODE
  LEFT JOIN (select FBRCID,
                    BRCNAME,
                    rank() OVER(PARTITION BY FBRCID ORDER BY SYSMODDATE desc) AS rank1
               from ods.tcsv_pubbranchinfo) T8
    ON T8.FBRCID = T5.FBRCID
   AND T8.rank1 = 1
  LEFT JOIN (select SMPBRCCODE,
                    BRCNAME,
                    row_number() OVER(PARTITION BY SMPBRCCODE ORDER BY SYSMODDATE desc) as rank1
               FROM ods.tcsv_pubbranchmap) T9
    ON T5.SMPBRCCODE = T9.SMPBRCCODE
   AND T9.rank1 = 1
  LEFT JOIN (select UCBRCCODE,
                    BRCNAME,
                    row_number() OVER(PARTITION BY UCBRCCODE ORDER BY SYSMODDATE desc) as rank1
               FROM ods.tcsv_pubbranchmap) T10
    ON T5.UCBRCCODE = T10.UCBRCCODE
   AND T10.rank1 = 1
 WHERE T3.ID IS NOT NULL
   AND T5.CONTRACTNO IS NOT NULL;
