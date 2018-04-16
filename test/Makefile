all:	tests

tests:
	export FN="tests-results-`date +%Y%m%d-%H%M%S`" ; \
	./test-all.sh > "$${FN}.log" && \
	./process-test-results.sh < "$${FN}.log" > "$${FN}.tap" && \
	./generate-compat-report.pl "$${FN}.tap" > "$${FN}.report"

clean:
	rm -f *~

