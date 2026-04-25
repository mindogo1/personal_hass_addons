# Pi-hole add-on

## v6.4.2

<!-- Release notes generated using configuration in .github/release.yml at development -->

## What's Changed
* Wipe version file before creating a new one by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6538
* Fix ownership permissions for containing directories in fix_owner_per… by @PromoFaux in https://github.com/pi-hole/pi-hole/pull/6589
* Remove reference to /usr/local/bin/COL_TABLE by @darkexplosiveqwx in https://github.com/pi-hole/pi-hole/pull/6594
* Skip apt cache update when pihole-meta is current by @PromoFaux in https://github.com/pi-hole/pi-hole/pull/6581
* Set versions in /etc/pihole/versions to null if script fails by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6550
* Remove redundant touching of logfiles from systemd Service by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6601
* Loosen requirements for local file access for gravity by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6430
* Fix permission for *.etag files after gravity run by @yubiuser in https://github.com/pi-hole/pi-hole/pull/6353
* add logrotate to DEB and RPM dependencies by @darkexplosiveqwx in https://github.com/pi-hole/pi-hole/pull/6524
* Improve gravity error message including curl exit code and errormsg by @rdwebdesign in https://github.com/pi-hole/pi-hole/pull/6605

## Security advisories
* https://github.com/pi-hole/pi-hole/security/advisories/GHSA-6w8x-p785-6pm4
  *  Fixed with : https://github.com/pi-hole/pi-hole/commit/7ccb8ddfb085479fa96e801886eb1cdbeaf3a720 and https://github.com/pi-hole/FTL/commit/88c569aa026d905d0066135bb71f36a13acf4bf4


**Full Changelog**: https://github.com/pi-hole/pi-hole/compare/v6.4.1...v6.4.2

[View on GitHub](https://github.com/pi-hole/pi-hole/releases/tag/v6.4.2)
