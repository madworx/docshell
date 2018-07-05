OS := ${OS}
DIR := ${DIR}

all:	tests

tests:
	./test-all.sh $(OS) | \
	./process-test-results.pl 

generate-report:
	cat ${DIR}/*.tap > .tap
	./generate-compat-report.pl .tap

clean:
	rm -f *~
