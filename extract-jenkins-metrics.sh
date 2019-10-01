#!/bin/sh
rm -f all-plugins-with-url.txt
rm -f all-pom-xml-urls.txt

IFS=$'\n'       # make newlines the only separator

for line in $(cat all-plugins-with-version.txt); do
  i=$(echo $line | cut -f1 -d\ )
  v=$(echo $line | cut -f2 -d\ )
  urls=$(curl -s https://plugins.jenkins.io/$i | grep -Eo 'https://github.com/jenkinsci/[^/(\)"]+' | uniq  )
  # Multiple github url founds in out
  if [ "$(echo $urls | head -1 )" != "$urls" ]; then
    if [ -z "$url" ]; then
          # Check if on url is exact match@
          url=$( echo $urls |grep -Eo "https://github.com/jenkinsci/$i$" |  uniq | head -1 )
          pom_url="$url/raw/master/pom.xml"
    fi
    #url=$( echo $urls |  grep -Eo "https://github.com/jenkinsci/$i$"  )
    if [ -z "$url" ]; then
      url=$( echo $urls |  grep -Eo "https://github.com/jenkinsci/$i-plugin$" )
      pom_url="$url/raw/master/pom.xml"
    fi
    #https://github.com/jenkinsci/js-libs/tree/master/handlebars
    if [ -z "$url" ]; then
      url=$( echo $urls |  grep -Eo "https://github.com/jenkinsci/js-libs/tree/master/$i$")
      pom_url="https://github.com/jenkinsci/js-libs/raw/master/$i/pom.xml"
    fi
    # https://github.com/jenkinsci/blueocean-plugin/blueocean-pipeline-editor
    if [ -z "$url" ]; then
      url="https://github.com/jenkinsci/blueocean-plugin/tree/master/$i" 
      pom_url="https://github.com/jenkinsci/blueocean-plugin/raw/master/$i/pom.xml"
    fi
  else
    url=$urls
    pom_url="$url/raw/master/pom.xml"
  fi
  echo "$i $url"
  echo "$i $url" >> all-plugins-with-url.txt
  echo "git clone $url; git checkout release-v$v" >> checkout-all-plugins-with-version.txt
  echo "$pom_url" >> all-pom-xml-urls.txt
  unset url
  unset pom_url
 done

