#!/bin/bash
 
domain=$1
# 1- Passive Enumeration
 
domain_enum() {
	mkdir -p $domain $domain/sources $domain/Recon $domain/Recon/nuclei/
	subfinder -d $domain -o $domain/sources/subfinder.txt
	assetfinder --subs-only $domain | tee $domain/sources/assetfinder.txt
	findomain -t $domain -q | tee $domain/sources/find-domain.txt
	waybackurls $domain | unfurl -u domains | tee $domain/sources/wayback.txt
	cat $domain/sources/*.txt > $domain/sources/all.txt
	cat $domain/sources/all.txt | httpx -l $domain/sources/all.txt -o "$domain/sources/live_domains.txt"
	python3 /home/masaud/Desktop/tools/waymore/waymore.py -i "$domain" -mode U -oU "$domain/sources/waymore.txt"
	cat $domain/sources/live_domains.txt | katana -f qurl -silent -kf all -jc -aff -d 5 -o "$domain/sources/katana-param.txt"
	grep -E -i -o '\S+\.(cobak|backup|swp|old|db|sql|asp|aspx|aspx~|asp~|py|py~|rb|rb~|php|php~|bak|bkp|cache|cgi|conf|csv|html|inc|jar|js|json|jsp|jsp~|lock|log|r(ar|)\.old|sql|sql\.gz|sql\.zip|sql\.tar\.gz|sql~|swp|swp~|tar|tar\.bz2|tar\.gz|txt|wadl|zip|log|xml|json)\b' "$domain/sources/waymore.txt" "$domain/sources/katana-param.txt" | sort -u > $domain/sources/interesting.txt
	cat "$domain/sources/waymore.txt" "$domain/sources/katana-param.txt" | sort -u | grep "=" | qsreplace 'FUZZ' | egrep -v '(.css|.png|blog|utm_source|utm_content|utm_campaign|utm_medium|.jpeg|.jpg|.svg|.gifs|.tif|.tiff|.png|.ttf|.woff|.woff2|.ico|.pdf|.svg|.txt|.gif|.wolf)' > "$domain/sources/waymore-katana-unfilter-urls.txt"
	cat "$domain/sources/waymore-katana-unfilter-urls.txt" | httpx -t 150 -rl 150 -o "$domain/sources/waymore-katana-filter-urls.txt"
	grep = $domain/sources/waymore-katana-filter-urls.txt >> $domain/sources/parameters_with_equal.txt
   }
 
domain_enum
 
scanner(){
nuclei -t /home/masaud/Desktop/tools/fuzzing-templates/ -l "$domain/sources/parameters_with_equal.txt" #change according to your LOCAL PATH
nuclei -l $domain/sources/live_domains.txt -o "$domain/sources/parameters_with_equal.txt"
}
scanner
