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

rm -rf .paper
mkdir -p .paper
cd .paper || exit

git clone https://github.com/PaperMC/Paper.git
api=$(download https://github.com/monun/paper-api/releases/latest/download/paper-api.jar .)

for version in "$@"; do
  commit=$($_java -jar "$api" -r commit -v "$version" -b "latest")

  if [[ $commit == *"error"* ]]; then
    echo "No such build for $version"
    continue
  fi

  echo "$version = $commit"
  cd Paper || exit
  git checkout "$commit"
  ./gradlew applyPatches
  ./gradlew publishToMavenLocal
  ./gradlew clean
  cd .. || exit
done
