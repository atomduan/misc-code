use mofi_instra;
CREATE TABLE `user_deduct_info_wechat` (
      `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
      `user_deduct_info_id` bigint(20) unsigned NOT NULL DEFAULT '0',
      `extra_info` varchar(1024) DEFAULT NULL,
      `create_time` bigint(20) NOT NULL DEFAULT '0',
      `update_time` bigint(20) NOT NULL DEFAULT '0',
      `mi_id` bigint(20) NOT NULL DEFAULT '0',
      `openid` varchar(1024) DEFAULT NULL,
      `contract_code` varchar(1024) DEFAULT NULL,
      `contract_id` varchar(1024) DEFAULT NULL,
      `plan_id` varchar(1024) DEFAULT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8  COMMENT ="微信代扣签约补充信息表,会保存签约上传和回调的相关信息";

use mofi_instra;
alter table user_deduct_info add column (
    `channel` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '支付渠道 1.支付宝 2.微信 4.小米钱包',
    is_deleted int(32) unsigned NOT NULL DEFAULT '0' COMMENT '渠道状态,是否已经被删除（禁用）０.否，1.是'
);
alter table user_deduct_info add CONSTRAINT `uk_mi_id_channel` UNIQUE (`mi_id`, `channel`);
alter table user_deduct_info drop index uk_mi_id;

use mofi_instra_payment;
update deduct_trade_detail set channel=4 where channel=0 and id>0 and id<4999;
update deduct_trade_detail set channel=4 where channel=0 and id>4998 and id<9999;
update deduct_trade_detail set channel=4 where channel=0 and id>9998 and id<14999;
update deduct_trade_detail set channel=4 where channel=0 and id>14998 and id<19999;
update deduct_trade_detail set channel=4 where channel=0 and id>19998 and id<24999;
update deduct_trade_detail set channel=4 where channel=0 and id>24998 and id<29999;
update deduct_trade_detail set channel=4 where channel=0 and id>29998 and id<34999;
update deduct_trade_detail set channel=4 where channel=0 and id>34998 and id<39999;
update deduct_trade_detail set channel=4 where channel=0 and id>39998 and id<44999;
update deduct_trade_detail set channel=4 where channel=0 and id>44998 and id<49999;
update deduct_trade_detail set channel=4 where channel=0 and id>49998 and id<54999;
update deduct_trade_detail set channel=4 where channel=0 and id>54998 and id<59999;
update deduct_trade_detail set channel=4 where channel=0 and id>59998 and id<64999;
update deduct_trade_detail set channel=4 where channel=0 and id>64998 and id<69999;
update deduct_trade_detail set channel=4 where channel=0 and id>69998 and id<74999;
update deduct_trade_detail set channel=4 where channel=0 and id>74998 and id<79999;
update deduct_trade_detail set channel=4 where channel=0 and id>79998 and id<84999;
update deduct_trade_detail set channel=4 where channel=0 and id>84998 and id<89999;
update deduct_trade_detail set channel=4 where channel=0 and id>89998 and id<94999;
update deduct_trade_detail set channel=4 where channel=0 and id>94998 and id<99999;
update deduct_trade_detail set channel=4 where channel=0 and id>99998 and id<104999;
update deduct_trade_detail set channel=4 where channel=0 and id>104998 and id<109999;
