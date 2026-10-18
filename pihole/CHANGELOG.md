# Pi-hole add-on

## v6.5

<!-- Release notes generated using configuration in .github/release.yml at development -->

## Security

This release fixes the following security advisories (credit to the reporters named):

**High**
- [GHSA-cf36-4hhc-8398](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-cf36-4hhc-8398) (CVSS 7.8): command execution via a crafted PID. Reported by @abdoghazy2015.
- [GHSA-xch2-4qxw-g5vj](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-xch2-4qxw-g5vj) (CVSS 7.8): root following a symlink when writing the version file. Reported by @keithlinneman and @KimiSecurityTeam.
- [GHSA-j8vh-6fp9-cjcx](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-j8vh-6fp9-cjcx) (CVSS 7.8): `/opt/pihole` is now read-only for the FTL service. Reported by @keithlinneman.
- [GHSA-mff6-cjc4-5wq9](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-mff6-cjc4-5wq9) (CVSS 7.3): root writing to config-supplied paths. Reported by @KimiSecurityTeam, @keithlinneman and @Pedromdsn.

**Low**
- [GHSA-g63w-24cr-p3w6](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-g63w-24cr-p3w6) (CVSS 2.2): the `file://` adlist read check and curl could resolve different files. Local lists are now read as the user whose access was checked.

## What's Changed

- Stop double-rotating logs now that `pihole` is in `/etc/logrotate.d`.
- Remove the deprecated `arpflush` command in favour of `networkflush`.
- Improve gravity error handling.
- Fix unquoted variable expansion in `rm` paths.
- Send `USR2` after logrotate.
- Keep `/etc/pihole/versions` readable by all users.
- Remove Debian 11 from the CI distro matrix.
- Fix URL parsing in `gravity.sh`.
- Improve the gravity database schema for performance: `WITHOUT ROWID` junction tables, new indexes for group lookups and cheaper triggers. Existing databases are migrated to schema version 21 on update.
- Store the `listsCache` directory next to `gravity.db` instead of always in `/etc/pihole`.
- Run the update checker and the FTL prestart file fix-ups as the `pihole` user, and only trust git repositories the `pihole` user cannot modify.
- Read local `file://` adlists as the user whose access was checked, instead of via curl.
- Parse local `file://` adlist URIs with parameter expansion and path canonicalisation (RFC 8089), by @mwoolweaver.
- Pass the adlist source URL to FTL's `parseList` (needed by the FTL v6.8 `file://` adlist fix).
- Flush the last 24 hours of queries through the FTL API instead of touching the database directly.
- Stop granting `CAP_CHOWN` to everything `pihole-FTL` executes (kept in the ambient set of the FTL service).

## New Contributors

* @candygoogy made their first contribution in https://github.com/pi-hole/pi-hole/pull/6711

**Full Changelog**: https://github.com/pi-hole/pi-hole/compare/v6.4.3...v6.5

[View on GitHub](https://github.com/pi-hole/pi-hole/releases/tag/v6.5)
