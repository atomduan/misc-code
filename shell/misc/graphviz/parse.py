#!/usr/bin/python

#fetch the artifactId of the input pom.xml
#and it's dependencies artifactId

inparent = False
depbegin = False

artifact = ''
deps = []

def main(argv):
    global inparent
    global depbegin
    global artifact
    global deps

    f = open(argv[1])
    for l in f.readlines():
        l = l.strip()
        if l.find('<parent>') >= 0:
            #print l
            inparent = True
        if inparent == True:
            if l.find('</parent>') >= 0:
                inparent = False
                #print l

        if l.find('<dependencies>') >= 0:
            #print l
            depbegin = True
        if depbegin == True:
            if l.find('</dependencies>') >= 0:
                depbegin = False
                #print l

        if l.find('<artifactId>') >= 0:
            if l.find('mifi-') >= 0:
                if not depbegin and not inparent:
                    l = l.replace('<artifactId>','')
                    l = l.replace('</artifactId>','')
                    artifact = l
                if depbegin:
                    l = l.replace('<artifactId>','')
                    l = l.replace('</artifactId>','')
                    deps.append(l)

    if len(l) == 0:
        print "############" + argv[1] + "##############"

    for d in deps:
        print d + " -> " + artifact + ";"

    if len(l) == 0:
        print "############" + argv[1] + "##############"


if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
