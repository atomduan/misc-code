#!/bin/bash
#BACK GROUND: we need to dump our hive meta structure to mysql, all table schema info to our mysql db.
hive -e 'show databases;' > target_db.list
cat target_db.list | xargs -I{} bash -c "(hive -e 'use {}; show tables;' 2>/dev/null | xargs -I[] echo {}.[])" | grep -v 'Fetched:' > tables.list
#cat two lines togather
cat table_detail.list | grep 'Table(' | head | grep -oE '(tableName:[^ ]*|cols:\[[^]]*\])' | sed 'N; s/\n//g'
#run split process
cat target_db.list | while read db; do (cat tables.list | grep "^${db}\." | awk '{print "describe extended "$0";"}'> ./tables/${db}_desc_cmd.list); done
cat target_db.list | while read db; do echo "process $db...."; (hive -f ./tables/${db}_desc_cmd.list > ./result/${db}.txt 2>/dev/null); done
cat target_db.list | while read db; do (cat ${db}.txt | sed '/Detailed/s/, dbName:.*/\n----/g' | sed '/Detailed Tab/s/.*Table(/TT_/g' | grep -v '#' | awk 'NF' > ${db}.final); done
#back up current db
mysqldump -uroot -proot -B metaplate > metaplate.sql
cat target_db.list | while read l; do echo "INSERT INTO data_base (name, host_id, db_type) VALUES ('${l}', 1,'hive');"; done > insert_db.sql
mysql -uroot -proot --database metaplate < insert_db.sql
cat target_db.list | while read db; do (cat final/${db}.final | sed 's/\t//g'|tr -s ' ' |./import.py ${db} table >> insert_table.sql); done
mysql -uroot -proot -B metaplate < insert_table.sql
mysql -uroot -proot -e 'select name, id from metaplate.data_table' > tables.dict
cat target_db.list | while read db; do (cat final/${db}.final | grep -v 'serialization.format' | sed 's/\t/ /g' |./import.py ${db} field >> insert_field.sql); done
mysql -uroot -proot -B metaplate < insert_field.sql
