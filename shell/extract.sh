#!/bin/bash -
if [ -f "total.ts" ]; then
    rm total.ts
fi

#HTTP Archive file
har_file=$@

if ! [ -f "$har_file" ]; then
    echo "har file not exist..."
    exit 1
fi

cat $har_file | 
    grep '\.ts' | uniq | grep https | awk '{print $2}' | 
        sed 's/"//g' | sed 's/,//g' | 
            xargs -I{} bash -c "(echo {} --------- ;curl {} >> total.ts)"
