# omarchy-muslimtify

An Omarchy shell bar widget for [muslimtify](https://github.com/muslimtify-org/muslimtify). The bar shows the next prayer. Click it for today's prayer times and every muslimtify setting.

Needs [muslimtify](https://muslimtify.vercel.app) installed and on your PATH.

https://github.com/user-attachments/assets/ca837af0-7132-4384-aba0-0535c539fbf0

## Install

```bash
omarchy plugin add https://github.com/muslimtify-org/omarchy-muslimtify --enable
```

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
