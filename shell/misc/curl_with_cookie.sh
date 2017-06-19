#!/bin/bash -
#this example shows how to use curl under login required condition
#the --cookie opt need to be properage with certain values, which we can get from browser like chrome or firefox tool bar.
#the -L option is used for forward circurmenstance
cat machine.list | xargs -I{} curl --cookie 'xbox-deploy="oXOQfF+oSVWIQmQwPf+pJsY1acQ=?_expires=STE1MDA0NDk5NDQKLg==&_permanent=STAxCi4=&broker_cookies=Uyd4Ym94OjA3ZGFjNWU5YWUxYzk3Yjg3NjgwMDdkMjI4NTgzZGUyNmU0MWMzMzAnCnAxCi4=&tagstring=VmNvcC54aWFvbWlfb3d0Lm1pdWlfcGRsLkZJCnAxCi4=&user=VmR1YW5qdW50YW8KcDEKLg==&user_name=VmR1YW5qdW50YW8KcDEKLg=="; fiels=foobar' -L 'http://deploy.foo.com/api/v1/services/{}/instances' 2>/dev/null >machines.raw

