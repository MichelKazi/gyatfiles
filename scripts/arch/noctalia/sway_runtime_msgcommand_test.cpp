#include "compositors/sway/sway_runtime.h"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <print>
#include <string>
#include <unistd.h>

namespace {

  bool expect(bool condition, const char* message) {
    if (!condition) {
      std::println(stderr, "sway_runtime_msgcommand_test: {}", message);
    }
    return condition;
  }

  // Creates an executable stub named `name` inside `dir` so process::commandExists()
  // finds it on PATH exactly like a real swaymsg/i3-msg/scrollmsg binary would.
  void writeStub(const std::filesystem::path& dir, const std::string& name) {
    const std::filesystem::path path = dir / name;
    std::ofstream out(path);
    out << "#!/bin/sh\nexit 0\n";
    out.close();
    std::filesystem::permissions(path, std::filesystem::perms::owner_all);
  }

  class ScopedPath {
   public:
    explicit ScopedPath(const std::string& value) {
      if (const char* existing = std::getenv("PATH"); existing != nullptr) {
        m_previous = existing;
        m_hadPrevious = true;
      }
      ::setenv("PATH", value.c_str(), 1);
    }

    ~ScopedPath() {
      if (m_hadPrevious) {
        ::setenv("PATH", m_previous.c_str(), 1);
      } else {
        ::unsetenv("PATH");
      }
    }

   private:
    std::string m_previous;
    bool m_hadPrevious = false;
  };

  std::filesystem::path makeTempDir(const std::string& suffix) {
    const std::filesystem::path dir = std::filesystem::temp_directory_path()
        / ("noctalia_sway_runtime_test_" + suffix + "_" + std::to_string(::getpid()));
    std::filesystem::remove_all(dir);
    std::filesystem::create_directories(dir);
    return dir;
  }

  // Regression coverage for the scrollmsg fallback added to resolveCommands(): hosts running
  // only scroll (no swaymsg/i3-msg) left m_msgCommand empty before this fallback existed.
  // These exercise the real PATH lookup (process::commandExists), not a mock, so they'd
  // catch both a regression in the fallback and a regression in swaymsg/i3-msg precedence.

  bool scrollOnlyHostResolvesMsgCommandToScrollmsg() {
    const auto dir = makeTempDir("scroll_only");
    writeStub(dir, "scrollmsg");
    const ScopedPath scopedPath(dir.string());

    compositors::sway::SwayRuntime runtime;
    runtime.refresh();

    bool ok = expect(runtime.hasMsgCommand(), "scroll-only host should resolve a msgCommand");
    ok = expect(runtime.msgCommand() == "scrollmsg", "scroll-only host should fall back msgCommand to scrollmsg") && ok;
    ok = expect(runtime.hasOutputCommand(), "scroll-only host should resolve an outputCommand") && ok;
    ok = expect(runtime.outputCommand() == "scrollmsg", "scroll-only host outputCommand should be scrollmsg") && ok;

    std::filesystem::remove_all(dir);
    return ok;
  }

  bool swaymsgStillTakesPrecedenceOverScrollmsg() {
    const auto dir = makeTempDir("sway_precedence");
    writeStub(dir, "swaymsg");
    writeStub(dir, "scrollmsg");
    const ScopedPath scopedPath(dir.string());

    compositors::sway::SwayRuntime runtime;
    runtime.refresh();

    bool ok = expect(runtime.msgCommand() == "swaymsg", "swaymsg should still win over scrollmsg when both exist");
    ok = expect(runtime.outputCommand() == "scrollmsg", "outputCommand should still prefer scrollmsg when present") && ok;

    std::filesystem::remove_all(dir);
    return ok;
  }

  bool noKnownCommandsLeavesMsgCommandUnresolved() {
    const auto dir = makeTempDir("no_commands");
    const ScopedPath scopedPath(dir.string());

    compositors::sway::SwayRuntime runtime;
    runtime.refresh();

    bool ok = expect(!runtime.hasMsgCommand(), "host with no known IPC binaries should leave msgCommand unresolved");
    ok = expect(!runtime.hasOutputCommand(), "host with no known IPC binaries should leave outputCommand unresolved")
        && ok;

    std::filesystem::remove_all(dir);
    return ok;
  }

} // namespace

int main() {
  bool ok = true;
  ok = scrollOnlyHostResolvesMsgCommandToScrollmsg() && ok;
  ok = swaymsgStillTakesPrecedenceOverScrollmsg() && ok;
  ok = noKnownCommandsLeavesMsgCommandUnresolved() && ok;
  return ok ? 0 : 1;
}
