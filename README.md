# misc-code
happy coding and have fun

# vim pipe line by line g/{pattern}/ {command}
'<,'>g/^/ s/$/;/

# for select padding number
:let i=0 | '<,'>g/^/ s/^/\=printf("%05d",i)/g | let i+=1

# move your cursor on vim command line
ctrl+shift+left, ctrl+shift+right

# del blink line
:g/^$/d

# print word in vertical direction
echo abc | fold -1

# print pedding number in vim command line '%' need to be escaped
:r !seq 1 20 | xargs -I{} bash -c "printf '\%02d\n' {}"
