top:; @date

SHELL := /bin/bash -o pipefail

Makefile:;

include loghost.mk

h := .hashdeep
s := .sig-$(USER)
b := /space/remote_logs

rsync = rsync -aCv
get: $h $s; mkdir -p $^; echo $^ | xargs -n1 | xargs -i $(rsync) $(DRY) root@$(loghost):$b/{} .
put:; $(rsync) $(DRY) --exclude '*$h' $h/ root@$(loghost):$b/$s

hashdeep := $(wildcard $h/*$h)
ascsig := $(hashdeep:%=%.asc)

sig: $(ascsig)
chk: $(hashdeep); @echo $^ | xargs -n1 | xargs -i gpg --verify {}.asc {}
cmp: $(ascsig); @echo $(^:$h/%=%) | xargs -n1 | xargs -i cmp $h/{} $s/{}

$h/%.asc: $h/%; test -f $@ || gpg -ba $< && chmod 444 $@

main := get sig put chk cmp
main: $(main)

mk := hashdeep_space_remote_log.mk
rmk := /usr/local/bin/$(mk)
sync:; $(rsync) $(RUN) root@$(loghost):$(rmk) .
init:; $(rsync) $(RUN) $(mk) root@$(loghost):$(rmk)

RUN := -n
run := RUN :=

DRY :=
dry := DRY := -n

vartar := dry run
$(vartar):; @: $(eval $($@))

.PHONY: top $(main) sync init $(vartar)

