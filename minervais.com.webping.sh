#!/bin/bash
#minervais.com.webping.sh

timeout=1 #increase value to yield fewer false negatives (but decrease speed!)

#check dependencies
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
	echo "curl or wget is needed for this script to run"
	exit
elif [[ $# -ne 1 ]]; then
	echo -e "one argument expected. correct syntax:\n$0 <fqdns-or-ips-file>"
	exit
fi

cat $1|while read t
do 
	#https
	for p in 443 8443; do
		if command -v curl >/dev/null 2>&1; then
			if curl -Iiks -m $timeout https://$t:$p|grep ^HTTP\/>/dev/null 2>&1; then
				echo "https://$t:$p"
			fi
		elif command -v wget >/dev/null 2>&1; then
			if wget --quiet -S --no-check-certificate --spider --timeout=$timeout -O /dev/null --tries 1 --max-redirect=0 https://$t:$p 2>&1|grep HTTP\/>/dev/null 2>&1; then
				echo "https://$t:$p"
			fi
		fi
	done

	#http
	for p in 80 8000 8008 8080 8081; do
		if command -v curl >/dev/null 2>&1; then
			if curl -Iis -m $timeout http://$t:$p|grep ^HTTP\/>/dev/null 2>&1; then
				echo "http://$t:$p"
			fi
		elif command -v wget >/dev/null 2>&1; then
			if wget --quiet -S --spider --timeout=$timeout -O /dev/null --tries 1 --max-redirect=0 http://$t:$p 2>&1|grep HTTP\/>/dev/null 2>&1; then
				echo "http://$t:$p"
			fi
		fi
	done
done
