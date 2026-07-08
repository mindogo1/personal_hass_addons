# Pi-hole add-on

## v6.4.3

<!-- Release notes generated using configuration in .github/release.yml at master -->

## Security Fixes

- [pi-hole/pi-hole/security/advisories/GHSA-h8w9-qx2v-wrww](https://github.com/pi-hole/pi-hole/security/advisories/GHSA-h8w9-qx2v-wrww) — Local privilege escalation from pihole user to root via /etc/pihole/logrotate (High) reported by [supperhellokitty20](https://github.com/supperhellokitty20)

## What's Changed
* Also hardcode the PID file location in utils.sh to prevent `readonly  variable` warning by @PromoFaux in https://github.com/pi-hole/pi-hole/pull/6613
* Use `awk` to compare curl versions by @rdwebdesign in https://github.com/pi-hole/pi-hole/pull/6621
* Explicitly add `gawk` to APK dependencies by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6622
* Prevent double error message output in gravity run with invalid file by @PromoFaux in https://github.com/pi-hole/pi-hole/pull/6607
* Replace pytest/tox with direct in-container BATS by @PromoFaux in https://github.com/pi-hole/pi-hole/pull/6598
* Add Fedora 44 and Ubuntu 26.04 LTS to tests by @darkexplosiveqwx in https://github.com/pi-hole/pi-hole/pull/6623
* Add gravity tests by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6639
* Set BATS pretty output flag depending on the terminal and improve failure output by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6644
* fix: check return codes in gravity_build_tree and database_recovery() by @jluzzi123 in https://github.com/pi-hole/pi-hole/pull/6630
* Include alpine 3.24 in tests by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6654
* installer: fix custom DNS entry when only one upstream server is provided by @Gilmoursa in https://github.com/pi-hole/pi-hole/pull/6638
* Fix BATS gravity test on curl version >=8.21 by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6661
* avoid copytruncate in logrotate by @darkexplosiveqwx in https://github.com/pi-hole/pi-hole/pull/6642
* v6.4.3 by @PromoFaux in https://github.com/pi-hole/pi-hole/pull/6618

## New Contributors
* @jluzzi123 made their first contribution in https://github.com/pi-hole/pi-hole/pull/6630
* @Gilmoursa made their first contribution in https://github.com/pi-hole/pi-hole/pull/6638

**Full Changelog**: https://github.com/pi-hole/pi-hole/compare/v6.4.2...v6.4.3

[View on GitHub](https://github.com/pi-hole/pi-hole/releases/tag/v6.4.3)
