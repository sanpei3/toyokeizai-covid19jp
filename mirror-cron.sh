#!/usr/local/bin/bash
WORKING_PATH=/home/sanpei/src/toyokeizai-covid19jp
to_address="sanpei@sanpei.org"
COVID_DATA_FILE="data.json"
URL="https://toyokeizai.net/sp/visual/tko/covid19/data/data.json"
DIFF="${COVID_DATA_FILE}.diff"

CURL="/usr/local/bin/curl"
FETCH="/usr/bin/fetch"
MAIL="/usr/bin/mail"
GIT="/usr/local/bin/git"

cd ${WORKING_PATH}
/bin/rm ${COVID_DATA_FILE}
${GIT} pull
if [ $? -ne 0 ]; then
    echo update ${COVID_DATA_FILE} | ${MAIL} -s "Toyokeizai covid19git pull error" ${to_address}
    exit
fi

#${CURL} -o ${COVID_DATA_FILE} ${URL}
# currently I cannot find the way to get error code. so I use fetch in FreeBSD
${FETCH} ${URL}
if [ $? -ne 0 ]; then
    echo update ${COVID_DATA_FILE} | ${MAIL} -s "Toyokeizai covid19download ERROR" ${to_address}
    exit
fi
if [ ! -s ${COVID_DATA_FILE} ]; then
    echo update ${COVID_DATA_FILE} | ${MAIL} -s "Toyokeizai covid19download SIZE ZERO ERROR" ${to_address}
    exit
fi

${GIT} diff ${COVID_DATA_FILE} > ${DIFF}
if [ ! -s ${DIFF} ]; then
	exit
fi
${GIT} commit -uno -m "`/bin/date`" ${COVID_DATA_FILE}
if [ $? -ne 0 ]; then
    echo update ${COVID_DATA_FILE} | ${MAIL} -s "Toyokeizai covid19git commit error" ${to_address}
    exit
fi
${GIT} push -u origin master
if [ $? -ne 0 ]; then
    echo update ${COVID_DATA_FILE} | ${MAIL} -s "Toyokeizai covid19git push error" ${to_address}
    exit
fi
