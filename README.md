# omarchy-muslimtify

An Omarchy shell bar widget for [muslimtify](https://github.com/muslimtify-org/muslimtify). The bar shows the next prayer. Click it for today's prayer times and every muslimtify setting.

Needs [muslimtify](https://muslimtify.vercel.app) installed and on your PATH.

https://github.com/user-attachments/assets/ca837af0-7132-4384-aba0-0535c539fbf0

## Install

```bash
omarchy plugin add https://github.com/muslimtify-org/muslimtify-omarchy --enable
```

## Remove

```bash
omarchy plugin disable muslimtify-org.muslimtify
omarchy plugin remove muslimtify-org.muslimtify
```

## Dependencies

- [muslimtify](https://github.com/muslimtify-org/muslimtify) on your PATH. Tested with v0.4.3. The time format setting needs v0.4.3 or later. Without it the bar shows only an icon and the popup says muslimtify was not found. The plugin does not install or manage the muslimtify daemon, which sends the notifications.
- `timedatectl`, for the timezone list in settings. It ships with systemd, so Omarchy already has it.
- `xdg-open`, for the GitHub and website links in the popup. Omarchy already has it.

The tests also need `node`, `jq` and `qmllint`. The plugin does not use them at runtime.

## License

MIT. See [LICENSE](LICENSE).

## Develop

Link your checkout into the plugins directory, then restart the shell. Run omarchy-restart-shell again after each change, because a plugin rescan does not reload code behind a symlink.

```bash
ln -s "$PWD" ~/.config/omarchy/plugins/muslimtify-org.muslimtify
omarchy-restart-shell
```

## Test

```bash
test/all.sh
```

The CLI test runs muslimtify against a temporary `HOME`, so it never touches your real config.
