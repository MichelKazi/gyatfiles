export SBT_OPTS="-Xmx16G -Xss4M"
export _JAVA_OPTIONS="--add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.sql/java.sql=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED"

alias sbt="DOCKER_BUILDKIT=1 DOCKER_DEFAULT_PLATFORM=linux/amd64 sbt"
