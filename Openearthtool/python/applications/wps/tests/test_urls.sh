#/bin/bash
while read url
do
    curl  -o /dev/null -g -sw "%{url_effective}\t %{http_code}\t %{redirect_url}\\n" $url
done < urls.txt
