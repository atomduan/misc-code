# misc-code
happy coding and have fun

# vim pipe line by line g/{pattern}/ {command}
'<,'>g/^/ s/$/;/

# for select padding number
:let i=0 | '<,'>g/^/ s/^/\=printf("%05d",i)/g | let i+=1

# move your cursor on vim command line
ctrl+shift+left, ctrl+shift+right

# del blank line
:g/^$/d

# print word in vertical direction
echo abc | fold -1

# print pedding number in vim command line '%' need to be escaped
:r !seq 1 20 | xargs -I{} bash -c "printf '\%02d\n' {}"

# print out each log's size
cat foolog | awk '{print $11, length($0)}' | awk '{stat[$1] += $2} END {for(i in stat){print i":"stat[i]}}' | sort -t':' -n -k3,3

# print params in multi lines
cat foo.log | sed -n '/getloginappaccount.v2/,/^2021-04-/p' |
    sed "s/^2021-04.\+/AAAAA/g" | uniq |
        grep -E '(^imei:|^oaid:|AAAAA)' |
            awk 'BEGIN{buf=""}{if($1=="AAAAA") print buf, buf=""; if($1!="AAAAA") buf = buf" "$0;}'

# conditional awk
seq 1 100 | awk 'BEGIN {mat = 0}{ if ($1~/^1/) { if (mat == 0) {print $0;mat = 1;} } else { print $0} } '

# conditianl print first word of '1' headed, other line print normally
seq 100 | sed -n '/^1/bx ; p; D; :x; {x; /^$/bz; D; :z; g; p;};'

# g global match, and delete empty lines
1,%g/^$/ d
