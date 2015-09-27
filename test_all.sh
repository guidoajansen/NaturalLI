#!/usr/bin/env sh
#

set -e
set -o xtrace

export MAXMEM_GB=6
export SCALA_HOME=${SCALA_HOME-/home/gabor/programs/scala}
echo "Scala at: $SCALA_HOME"

configure() {
  local SFM=${SEARCH_FULL_MEMORY:-"1"}
  ./configure \
    --with-scala=$SCALA_HOME \
    --with-java=/usr/lib/jvm/java-8-oracle \
    --with-corenlp=$HOME/stanford-corenlp.jar \
    --with-corenlp-models=$HOME/stanford-corenlp-models-current.jar \
    --with-corenlp-caseless-models=$HOME/stanford-corenlp-caseless-models-current.jar \
    --with-naturalli-models=$HOME/naturalli-models.jar \
    --enable-debug SEARCH_FULL_MEMORY=$SFM $@
  make clean
}

echo "-- CLEAN --"
git clean -f
rm -f etc/.have_models
rm -f etc/.pp_affinity
rm -f etc/.mk_graph
./autogen.sh

echo "-- MAKE --"
configure
make all check TESTS_ENVIRONMENT=true 
make src/naturalli_preprocess.jar

echo "-- DOCUMENT --"
doxygen doxygen.conf

echo "-- C++ TESTS --"
test/src/naturalli_test

#echo "-- JAVA TESTS --"
#make java_test
#
#echo "-- MAKE DIST --"
#configure
#make dist
#tar xfz `find . -name "naturalli-2.*.tar.gz"`
#cd `find . -type d -name "naturalli-2.*"`
#configure
#make all check
#cd ..
#rm -r `find . -type d -name "naturalli-2.*"`
#
#echo "-- C++ SPECIAL TESTS --"
#echo "(no debugging)"
#configure --disable-debug
#make check
#echo "(fuzzy matches)"
#configure MAX_FUZZY_MATCHES=8
#make check
#echo "(two pass hash)"
#configure TWO_PASS_HASH=1
#make check
#echo "(search cycle memory)"
#configure SEARCH_FULL_MEMORY=0 SEARCH_CYCLE_MEMORY=1; make check
#configure SEARCH_FULL_MEMORY=0 SEARCH_CYCLE_MEMORY=2; make check
#configure SEARCH_FULL_MEMORY=0 SEARCH_CYCLE_MEMORY=5; make check
#echo "(search full memory)"
#configure SEARCH_FULL_MEMORY=0; make check
#configure SEARCH_FULL_MEMORY=1; make check
#echo "(clang 3.5)"
#configure SEARCH_FULL_MEMORY=0 CXX=clang++-3.5; make check
#echo "(g++ 4.9)"
#configure SEARCH_FULL_MEMORY=0 CXX=g++-4.9; make check
#echo "(back to default)"
#configure  # reconfigure to default
#make all
#
#echo "-- COVERAGE --"
#make check
#cd src/
#rm -f naturalli_server-Messages.pb.gcda
#rm -f naturalli_server-Messages.pb.gcno
#rm -f naturalli_server-Messages.pb.h.gcno
#rm -f naturalli_server-Messages.pb.h.gcda
#/usr/bin/gcovr -r . --html --html-details -o /var/www/naturalli/coverage/index.html
#/usr/bin/gcovr -r . --xml -o coverage.xml
#cd ..
#
#echo "-- TEST CASES --"
#test/run_testcases.sh
#
#echo "-- DIST TEST CASES --"
#configure
#make dist
#tar xfz `find . -name "naturalli-2.*.tar.gz"`
#cd `find . -type d -name "naturalli-2.*"`
#configure
#make check
#test/run_testcases.sh
#cd ..
#rm -r `find . -type d -name "naturalli-2.*"`
#
#echo "-- TEST AND REPORT --"
#configure
#make all check TESTS_ENVIRONMENT=true 
#test/src/naturalli_test --gtest_output=xml:test/naturalli_test.junit.xml
#test/src/naturalli_itest --gtest_output=xml:test/naturalli_itest.junit.xml
#make java_test

echo "SUCCESS!"
exit 0