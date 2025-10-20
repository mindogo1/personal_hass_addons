#!/usr/bin/env bash
set -euo pipefail

OPT="/data/options.json"

# tiny JSON getters (no jq)
get_opt_str() {
  local key="$1"
  [[ -f "$OPT" ]] || { echo ""; return; }
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}

get_opt_array_items() {
  # prints each string item from a JSON array (e.g., ["a","b"]) on its own line
  local key="$1"
  [[ -f "$OPT" ]] || return 0
  sed -n "/\"$key\"[[:space:]]*:/,/]/p" "$OPT" \
    | tr -d '\n' \
    | sed -n "s/.*\"$key\"[[:space:]]*:\[ *\(.*\) *].*/\1/p" \
    | grep -o '"[^"]*"' | sed 's/^"//; s/"$//'
}

# Map add-on options -> env Pi-hole expects
export TZ="$(get_opt_str TZ || true)"
export WEBPASSWORD="$(get_opt_str WEBPASSWORD || true)"

export DNSMASQ_LISTENING="$(get_opt_str DNSMASQ_LISTENING || true)"
export ServerIP="$(get_opt_str ServerIP || true)"
export FTLCONF_LOCAL_IPV4="$(get_opt_str FTLCONF_LOCAL_IPV4 || true)"
export PIHOLE_DNS_1="$(get_opt_str PIHOLE_DNS_1 || true)"
export PIHOLE_DNS_2="$(get_opt_str PIHOLE_DNS_2 || true)"
export WEBTHEME="$(get_opt_str WEBTHEME || true)"
export CONDITIONAL_FORWARDING="$(get_opt_str CONDITIONAL_FORWARDING || true)"
export CONDITIONAL_FORWARDING_IP="$(get_opt_str CONDITIONAL_FORWARDING_IP || true)"
export CONDITIONAL_FORWARDING_DOMAIN="$(get_opt_str CONDITIONAL_FORWARDING_DOMAIN || true)"
export CONDITIONAL_FORWARDING_REVERSE="$(get_opt_str CONDITIONAL_FORWARDING_REVERSE || true)"

# Persist Pi-hole state under /data so HA snapshots back it up
DATA_BASE="/data/pihole"
ETC_PIHOLE="${DATA_BASE}/etc-pihole"
ETC_DNSMASQ="${DATA_BASE}/etc-dnsmasq.d"

mkdir -p "${ETC_PIHOLE}" "${ETC_DNSMASQ}"

# First run: copy any defaults, then replace with symlinks to persistent dirs
if [[ -d /etc/pihole && ! -L /etc/pihole ]]; then
  shopt -s nullglob dotglob
  if [[ -n "$(ls -A /etc/pihole)" ]]; then
    cp -a /etc/pihole/. "${ETC_PIHOLE}/" || true
  fi
  rm -rf /etc/pihole
fi
ln -sfn "${ETC_PIHOLE}" /etc/pihole

if [[ -d /etc/dnsmasq.d && ! -L /etc/dnsmasq.d ]]; then
  shopt -s nullglob dotglob
  if [[ -n "$(ls -A /etc/dnsmasq.d)" ]]; then
    cp -a /etc/dnsmasq.d/. "${ETC_DNSMASQ}/" || true
  fi
  rm -rf /etc/dnsmasq.d
fi
ln -sfn "${ETC_DNSMASQ}" /etc/dnsmasq.d

# ----- build wildcard rewrites file from options -----
WILDCARD_FILE="${ETC_DNSMASQ}/99-wildcards.conf"
: > "$WILDCARD_FILE"   # truncate

wild_count=0
while IFS= read -r item; do
  # expected formats: "*.domain=IP", ".domain=IP", "domain=IP"
  domain="${item%%=*}"
  ip="${item#*=}"

  # trim spaces
  domain="$(echo -n "$domain" | tr -d '[:space:]')"
  ip="$(echo -n "$ip" | tr -d '[:space:]')"

  # drop only a leading "*." or "." if present
  if [[ "$domain" == "*."* ]]; then
    domain="${domain#*.}"
  elif [[ "$domain" == "."* ]]; then
    domain="${domain#.}"
  fi

  # skip invalids
  if [[ -z "$domain" || -z "$ip" ]]; then
    continue
  fi

  # write both accepted forms; either is enough, but both removes ambiguity
  echo "address=/${domain}/${ip}"    >> "$WILDCARD_FILE"
  echo "address=/.${domain}/${ip}"   >> "$WILDCARD_FILE"
  ((wild_count++)) || true
done < <(get_opt_array_items "WILDCARDS")

echo "[pihole-addon] Persisted dirs:"
echo "  /etc/pihole    -> ${ETC_PIHOLE}"
echo "  /etc/dnsmasq.d -> ${ETC_DNSMASQ}"
echo "[pihole-addon] TZ=${TZ:-unset} DNSMASQ_LISTENING=${DNSMASQ_LISTENING:-unset} ServerIP=${ServerIP:-${FTLCONF_LOCAL_IPV4:-unset}}"
echo "[pihole-addon] Wildcards written (${wild_count}) to ${WILDCARD_FILE}:"
sed -n '1,200p' "$WILDCARD_FILE" || true

# Handoff to upstream init (s6-overlay v2: /s6-init, v3: /init)
if [ -x /s6-init ]; then
  exec /s6-init
elif [ -x /init ]; then
  exec /init
else
  echo "[pihole-addon] WARNING: No s6 init binary found. Starting services directly…"
  if command -v pihole >/dev/null 2>&1; then
    pihole -g || true
  fi
  if command -v pihole-FTL >/dev/null 2>&1; then
    pihole-FTL no-daemon &
  fi
  if command -v lighttpd >/dev/null 2>&1; then
    exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
  fi
  echo "[pihole-addon] No server binaries found. Idling for debug."
  exec tail -f /dev/null
fi
