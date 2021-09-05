#!/bin/bash

download() {
  wget -c --content-disposition -P "$2" -N "$1" 2>&1 | grep -Po '([A-Z]:)?[\/\.\-\w]+\.jar' | tail -1
}

# check java (https://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script)
if type -p java; then
  echo "Found java executable in PATH"
  _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
  echo "Found java executable in JAVA_HOME"
  _java="$JAVA_HOME/bin/java"
else
  echo "Not found java"
  exit
fi

rm -rf .spigot
mkdir -p .spigot
cd .spigot || exit

buildtools=$(download https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar .)

for version in "$@"; do
  $_java -jar "$buildtools" --rev "$version"
done
