# Pi-hole add-on

## v6.6

## Security

This release fixes the following security advisories (credit to the reporters named):

**High**
- [GHSA-wp3p-45h3-2v82](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-wp3p-45h3-2v82) (CVSS 7.3): `pihole -r` and `pihole -up` still followed symlinks in `/etc/pihole` when writing `install.log`, `migration_backup_v6` and `hosts/custom.list`, so a `pihole` user could get root to take over files of their choice. Found by @cerodah, reported by @pmagayon.
- [GHSA-5w4v-f65m-323f](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-5w4v-f65m-323f) (CVSS 7.3): root followed symlinks and config-supplied paths during the `macvendor.db` download, `pihole checkout` and `pihole uninstall`. Reported by @pmagayon.
- [GHSA-jvg9-fm8x-2jqq](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-jvg9-fm8x-2jqq) (CVSS 7.3): `pihole -d` followed symlinks in `pihole`-owned directories, so root copied arbitrary files into the debug log and overwrote or re-owned others. Found by @wyx98765, reported by @pmagayon.
- [GHSA-cq9w-mv93-mxh7](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-cq9w-mv93-mxh7) (CVSS 7.2): `gravity.sh` spliced `files.gravity` unescaped into SQL, which let an admin run commands as `pihole`. Core counterpart of FTL [GHSA-pj9m-9623-2g75](https://github.com/pi-hole/FTL/security/advisories/GHSA-pj9m-9623-2g75), which carries the CVE. Found by @Pedromdsn.

**Medium**
- [GHSA-qfq3-88xg-765w](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-qfq3-88xg-765w) (CVSS 5.3): the `pihole -d` debug log, and so a tricorder upload, included the web password hash, the app password hash and the TOTP secret. Reported by @pmagayon.

## What's Changed

- Drop from root to the `pihole` user with `setpriv` instead of `sudo`, so `sudo` is no longer required (#6752).
- The installer no longer writes into `/etc/pihole` as root. `install.log`, the v6 migration backup, `hosts/custom.list` and `macvendor.db` are written as `pihole`.
- `pihole checkout` writes `ftlbranch` as `pihole`. `pihole uninstall` only removes the web interface directory if it is the official checkout, and removes the configured databases as `pihole`.
- `pihole -d` does its work in `pihole`-owned directories as `pihole`, and leaves password hashes and the TOTP secret out of the debug log.
- `gravity.sh` escapes a custom `files.gravity` before using it in SQL.
- Rely on the system's daily logrotate instead of Pi-hole's own nightly forced run, which collided with it and rotated the logs twice (#6749).
- Fix `pihole flush quiet` still printing, and `pihole flush once` not finishing its status line (#6698).
- Fix `pihole updatechecker` writing `null` remote hashes to `/etc/pihole/versions` when run from `/root` (#6735).
- Warn when a local repository is not marked as safe for git, instead of `pihole -v` silently showing the version as N/A (#6746).
- Sample 1000 rows per index for `ANALYZE` (#6748).
- Mark Quad9's unfiltered upstream as validating DNSSEC (#6740).
- Expect no sample of non-domain entries for a local list (#6728).
- Remove the unneeded `CAP_IPC_LOCK` (#6726).
- Tests: add Fedora 45 (#6753) and allow running the test suite with podman (#6754).

## New Contributors

* @baseman70 made their first contribution in https://github.com/pi-hole/pi-hole/pull/6698
* @TooAngel made their first contribution in https://github.com/pi-hole/pi-hole/pull/6746

**Full Changelog**: https://github.com/pi-hole/pi-hole/compare/v6.5...v6.6

[View on GitHub](https://github.com/pi-hole/pi-hole/releases/tag/v6.6)
