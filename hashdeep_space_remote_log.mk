#!/usr/bin/make -f

top:; @date
.PHONY: top

s := hashdeep
b := /space/remote_logs
n ?= 1
d != date -d '-$n day' +%Y/%m/%d
p := $b/[a-z]*/$d
f := $(sort $(wildcard $p))
t := %/$s.txt
a := %/$s.audit
h := $(f:%=$t)
c := $(f:%=$a)

f = (cd $*; find -type f | grep -v $s | $s -f /dev/stdin $1)
$h: $t :; @$f > $@
$c: $a : $t; @echo -n $(@:$b/$a=%) ' '; $(call f, -k $< -a) | tee $@

g = echo $1 | xargs -n1 | (cd $b; $s -f /dev/stdin $2)
z := $b/.$s/$(subst /,-,$d).$s
$z: $h; @mkdir -p $(@D); $(call g, $(^:$b/%=%)) | tee $@

hash: $z; 
check: $z $c; @echo -n $(basename $(<F)) ' '; $(call g, $(c:$b/%.audit=%.txt), -k $< -a)
clean: $c; rm $^

.PHONY: hash check clean
