#!/usr/bin/env python3

def foo():
    global bar
    bar = 'inited'

def delta():
    kknd = bar
    #print("bar in delta --> " + str(bar))
    print("bar in delta --> " + str(kknd))
    #bar = 'redefine in delta'

#print("a --> " + str(bar))

#if __name__ == '__main__':
#    foo()
#    print("bar --> " + str(bar))

foo()
print("a --> " + str(bar))
delta()
print("b --> " + str(bar))
