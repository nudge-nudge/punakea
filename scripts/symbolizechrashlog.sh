#!/bin/bash

AWK_SCRIPT=/tmp/symbolizecrashlog_$$.awk
SH_SCRIPT=/tmp/symbolizecrashlog_$$.sh

if [[ $# < 2 ]]
then
	echo "Usage: $0 [ -arch <arch> ] symbol-file [ crash.log, ... ]"
	exit 1
fi

ARCH_PARAMS=''
if [[ "${1}" == '-arch' ]]
then
	ARCH_PARAMS="-arch ${2}"
	shift 2
fi

SYMBOL_FILE="${1}"
shift

cat > "${AWK_SCRIPT}" << _END
/^[0-9]+ +[-._a-zA-Z0-9]+ *\t0x[0-9a-fA-F]+ / {
	addr_index = index(\$0,\$3);
	end_index = addr_index+length(\$3);
	line_legnth = length;
	printf("echo '%s'\"\$(symbolize %s '%s')\"\n",substr(\$0,1,end_index),
		\$3,substr(\$0,end_index+1,line_legnth-end_index));
	next;
	}
{ gsub(/'/,"'\\\\''"); printf("echo '%s'\n",\$0); }
_END

function symbolize()
{
	# Translate the address using atos
	SYMBOL=$(atos -o "${SYMBOL_FILE}" ${ARCH_PARAMS} "${1}" 2>/dev/null)
	# If successful, output the translated symbol. If atos returns an address, output the original symbol
	if [[ "${SYMBOL##0x[0-9a-fA-F]*}" ]]
	then
		echo -n "${SYMBOL}"
	else
		echo -n "${2}"
	fi
}

awk -f "${AWK_SCRIPT}" $* > "${SH_SCRIPT}"

. "${SH_SCRIPT}"

rm -f "${AWK_SCRIPT}" "${SH_SCRIPT}"