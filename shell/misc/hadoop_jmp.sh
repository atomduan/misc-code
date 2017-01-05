#!/bin/bash -
sudo chown -R app:app /data/disk0/system/hadoop_sync
curr_cmd="$1"
shift
case "$curr_cmd" in
    "fs")
        curr_cmd="$1"
        shift
        case "$curr_cmd" in
            "-get")
                file_path="$1"
                shift
                dest_path="$1"
                shift
                if [ -d "$(dirname dest_path)" ]; then
                    sudo -i -u app ssh 10.120.65.68 -p2222 /opt/hadoop/bin/hadoop fs -get $file_path /home/app/hadoop_sync/ 2>/dev/null
                    sudo -i -u app rsync -a -l --progress '-e ssh -p 2222' --delete 10.120.65.68:/home/app/hadoop_sync/ /data/disk0/system/hadoop_sync
                    sudo chown -R root-root:root-root /data/disk0/system/hadoop_sync
                    cp -r /data/disk0/system/hadoop_sync/$(basename $file_path) $dest_path
                else
                    echo "dest dir $dest_path not existed...."
                    exit 1
                fi
                ;;
            "-put")
                file_path="$1"
                shift
                dest_path="$1"
                shift
                if [ -f "$file_path" ]; then
                    cp -r $file_path /data/disk0/system/hadoop_sync/
                    sudo chown -R app:app /data/disk0/system/hadoop_sync
                    sudo -i -u app rsync -a -l --progress '-e ssh -p 2222' --delete /data/disk0/system/hadoop_sync/ 10.120.65.68:/home/app/hadoop_sync
                    sudo -i -u app ssh 10.120.65.68 -p2222 /opt/hadoop/bin/hadoop fs -put /home/app/hadoop_sync/$(basename $file_path) $dest_path 2>/dev/null
                else
                    echo "dest file $file_path not existed....."
                    exit 1
                fi
                ;;
            *)
                sudo -i -u app ssh 10.120.65.68 -p2222 /opt/hadoop/bin/hadoop fs $curr_cmd $@ 2>/dev/null
                ;;
        esac
        ;;
    *)
        sudo -i -u app ssh 10.120.65.68 -p2222 /opt/hadoop/bin/hadoop $curr_cmd $@ 2>/dev/null
        ;;
esac
sudo chown -R app:app /data/disk0/system/hadoop_sync
