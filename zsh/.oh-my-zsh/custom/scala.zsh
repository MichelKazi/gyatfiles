# Shared Scala/sbt environment (all platforms)
export SBT_OPTS="-Xmx16G -Xss4M"
export _JAVA_OPTIONS="--add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.sql/java.sql=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED"

if [[ "$OSTYPE" == darwin* ]]; then
  # macOS (work dev): smart sbt wrapper — connects to existing server or starts one
  sbt() {
    local active_json="project/target/active.json"
    local project_name="${PWD##*/}"

    if [[ -f "$active_json" ]]; then
      echo "⚡ sbt server running for $project_name — connecting..."
      DOCKER_BUILDKIT=1 DOCKER_DEFAULT_PLATFORM=linux/amd64 command sbt --client "$@"
    else
      if [[ $# -eq 0 ]]; then
        echo "🚀 Starting sbt server for $project_name..."
        DOCKER_BUILDKIT=1 DOCKER_DEFAULT_PLATFORM=linux/amd64 command sbt
      else
        echo "🚀 Starting sbt for $project_name (--client will auto-start server)..."
        DOCKER_BUILDKIT=1 DOCKER_DEFAULT_PLATFORM=linux/amd64 command sbt --client "$@"
      fi
    fi
  }

  # Explicit thin client — always --client, never interactive
  sbtc() {
    DOCKER_BUILDKIT=1 DOCKER_DEFAULT_PLATFORM=linux/amd64 command sbt --client "$@"
  }
else
  # Linux / SteamOS: simple Docker-buildkit alias
  alias sbt="DOCKER_BUILDKIT=1 DOCKER_DEFAULT_PLATFORM=linux/amd64 sbt"
fi
