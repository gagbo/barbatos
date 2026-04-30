# Barbatos

Gerry Agbobada's customized [Universal Blue](https://universal-blue.org/) image, built on top of [Bluefin](https://projectbluefin.io/) using the multi-stage [finpilot](https://github.com/projectbluefin/finpilot) pattern.

## Architecture

Barbatos follows the same assembly model as upstream Bluefin, Aurora, and Bluefin LTS:

```
silverblue-main:43                  (Fedora GNOME base)
  + projectbluefin/common           (shared desktop config, ujust, motd, services)
  + ublue-os/brew                   (homebrew integration)
  + Barbatos system_files/          (thinkpad fan profiles, displaylink, udev rules)
  + Barbatos custom/                (niri/wayland session, extra packages, flatpak lists)
```

Each OCI container is a separate `COPY --from=` stage in the Containerfile, pinned to a SHA digest by Renovate. This gives:

- **Fast CI**: only changed layers are rebuilt
- **Small updates**: bootc rechunking produces ~5-10x smaller deltas
- **Shared maintenance**: desktop config improvements from `projectbluefin/common` flow in automatically

## What Barbatos adds

On top of the Bluefin-DX developer experience:

- **Niri compositor** with Noctalia shell, mako, fuzzel, foot, grim/slurp, swaylock/swayidle
- **Terminals & editors**: ghostty, helix, kitty
- **Theming**: matugen, brightnessctl, ImageMagick, fira-code-fonts
- **Hardware**: DisplayLink driver (DKMS), ThinkPad fan control (thinkfan), Framework fan control
- **Shells**: fish, starship, zsh
- **Security**: yubikey-manager, cosign
- **Sync**: syncthing
- **Flatpaks**: curated lists for generic, gaming, and work use cases
- **Homebrew**: CLI tools via Brewfile (atuin, bat, btop, eza, fd, fzf, gh, neovim, etc.)

## Repository layout

```
barbatos/
├── build/                  # Numbered build scripts (run inside container build)
│   ├── build.sh            # Orchestrator
│   ├── 10-copy-oci.sh      # Copy OCI containers + system_files into image
│   ├── 20-repos.sh         # Enable Copr + Terra repos
│   ├── 30-packages.sh      # Install Barbatos-specific packages
│   ├── 40-displaylink.sh   # DisplayLink DKMS driver
│   ├── 50-just-files.sh    # Validate ujust recipes
│   ├── 60-services.sh      # Enable systemd units
│   └── 90-cleanup.sh       # dnf clean + bootc lint
├── custom/
│   ├── brew/               # Brewfiles for CLI tools
│   ├── flatpaks/           # Flatpak app lists (generic, gaming, work)
│   └── ujust/              # Barbatos ujust recipes (barbatos.just)
├── system_files/           # Hardware-specific config (thinkfan, udev, systemd units)
├── iso/                    # ISO build config (iso.toml)
├── Containerfile           # Multi-stage build (finpilot pattern)
├── Justfile                # Local build/test commands
└── .github/workflows/      # CI (build + rechunk + sign, ISO, cleanup)
```

## Quick start

### Build locally

```bash
just build              # Build container image
just build-qcow2        # Build QCOW2 VM image
just run-vm-qcow2       # Test in browser-based VM
```

### Deploy

```bash
sudo bootc switch ghcr.io/gagbo/barbatos:stable
sudo systemctl reboot
```

### Post-install

```bash
ujust barb-install-apps   # Install flatpaks (generic + gaming + work)
ujust barb-install-clis   # Install CLI tools via homebrew
```

## Container signing

Images are signed with cosign. Verify with:

```bash
cosign verify --key cosign.pub ghcr.io/gagbo/barbatos:stable
```

See the [cosign setup section](#container-signing-setup) below if you're forking this repo.

### Container signing setup

1. `cosign generate-key-pair` (no password)
2. Add `cosign.key` contents as GitHub secret `SIGNING_SECRET`
3. Commit `cosign.pub` to the repo root
4. Never commit `cosign.key`

## Credits

- [Universal Blue](https://universal-blue.org/) and [Project Bluefin](https://projectbluefin.io/)
- [finpilot template](https://github.com/projectbluefin/finpilot)
- Inspired by [VeneOS](https://github.com/Venefilyn/veneos), [AmyOS](https://github.com/astrovm/amyos), [m2os](https://github.com/m2giles/m2os)

## License

Apache-2.0
