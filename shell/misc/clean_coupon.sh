#!/bin/bash -

cmd="mysql --host=10.138.163.6 --port=3306 --user=ket_wr --password=aaa --database=mket"

for i in {0..1000}; do 
    echo "$i......"
    dq='delete from pert_81 where user_id = "80381" and product_id = 701 and gert_id=1611 and pert_state = 1 limit 20000;'
    dsql="$cmd -e '$dq'"
    eval $dsql
done
