# gyatfiles
🍑Michel's dotfiles🍑


## macOS package inventory

`./install.sh --dry-run` previews setup; `./install.sh` installs packages and
registers the launch agents. The Brewfile preserves declared intent. A background
job captures packages installed with ordinary `brew install` commands every five
minutes and at login; the weekly job refreshes the other package snapshots too.

For immediate capture:

```sh
~/gyatfiles/scripts/sync-installed-packages.sh --brew-only
```

You can add declarations before installing them. Sync appends missing entries
without deleting or rewriting existing ones. To permanently remove a package,
uninstall it and remove its Brewfile declaration too. Review and commit the diff;
sync does not commit or push. Apps installed outside Homebrew are not captured.
Existing custom options are authoritative; changing install options through the
CLI does not rewrite them. Keep declarations on individual lines.

A failed snapshot leaves the previous file intact. Concurrent syncs are rejected.
If a sync is forcibly killed (SIGKILL), remove `scripts/packages/.sync-lock` after
checking that no sync process is running.
