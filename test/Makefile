OS := ${OS}
DIR := ${DIR}
SHELL=/bin/bash -o pipefail

all:	tests

check:
	shellcheck -s ksh *.sh 
	perl -Mstrict -cw *.pl
	perlcritic *.pl

tests:
	./test-all.sh $(OS) | \
	./process-test-results.pl 

generate-report:
	cat ${DIR}/*.tap > ${DIR}/.tap
	./generate-compat-report.pl ${DIR}/.tap

clean:
	rm -f *~
