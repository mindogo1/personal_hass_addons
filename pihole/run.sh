#!/usr/bin/env bash
set -euo pipefail

OPT="/data/options.json"

# --------- helpers (pure awk, no php/jq) ----------
get_opt_str() {
  local key="$1"
  [[ -f "$OPT" ]] || { echo ""; return; }
  awk -v k="\"$key\"" '
    BEGIN{found=0}
    $0 ~ k {
      # match:   "KEY" :  "value"
      if (match($0, "\"" key "\"[[:space:]]*:[[:space:]]*\"([^\"]*)\"", m)) { print m[1]; exit }
      found=1
    }
    found && /^[[:space:]]*"/ { # handle value on next line
      if (match($0, "\"([^\"]*)\"", m)) { print m[1]; exit }
    }
  ' key="$key" "$OPT"
}

get_opt_array() {
  # print each string item in array key on its own line
  local key="$1"
  [[ -f "$OPT" ]] || return 0
  awk -v key="$key" '
    BEGIN{inarr=0}
    $0 ~ "\"" key "\"[[:space:]]*:" { inarr=1; next }
    inarr {
      if ($0 ~ /\]/) { inarr=0; exit }
      while (match($0, /"([^"]*)"/, m)) {
        print m[1]
        $0 = substr($0, RSTART+RLENGTH)
      }
    }
  ' "$OPT"
}

# --------- map options to env Pi-hole expects ----------
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

# --------- persistence layout ----------
DATA_BASE="/data/pihole"
ETC_PIHOLE="${DATA_BASE}/etc-pihole"
ETC_DNSMASQ="${DATA_BASE}/etc-dnsmasq.d"
mkdir -p "${ETC_PIHOLE}" "${ETC_DNSMASQ}"

if [[ -d /etc/pihole && ! -L /etc/pihole ]]; then
  shopt -s nullglob dotglob
  [[ -n "$(ls -A /etc/pihole)" ]] && cp -a /etc/pihole/. "${ETC_PIHOLE}/" || true
  rm -rf /etc/pihole
fi
ln -sfn "${ETC_PIHOLE}" /etc/pihole

if [[ -d /etc/dnsmasq.d && ! -L /etc/dnsmasq.d ]]; then
  shopt -s nullglob dotglob
  [[ -n "$(ls -A /etc/dnsmasq.d)" ]] && cp -a /etc/dnsmasq.d/. "${ETC_DNSMASQ}/" || true
  rm -rf /etc/dnsmasq.d
fi
ln -sfn "${ETC_DNSMASQ}" /etc/dnsmasq.d

# --------- build wildcards file from config ----------
WILDCARD_FILE="${ETC_DNSMASQ}/99-wildcards.conf"
: > "$WILDCARD_FILE"

wild_count=0
while IFS= read -r item; do
  # Accept: "*.domain=IP" | ".domain=IP" | "domain=IP"
  domain="${item%%=*}"
  ip="${item#*=}"
  domain="$(echo -n "$domain" | tr -d '[:space:]')"
  ip="$(echo -n "$ip" | tr -d '[:space:]')"
  [[ "$domain" == "*."* ]] && domain="${domain#*.}"
  [[ "$domain" == "."*  ]] && domain="${domain#.}"
  if [[ -n "$domain" && -n "$ip" ]]; then
    echo "address=/${domain}/${ip}"  >> "$WILDCARD_FILE"
    echo "address=/.${domain}/${ip}" >> "$WILDCARD_FILE"
    ((wild_count++)) || true
  fi
done < <(get_opt_array "WILDCARDS")

echo "[pihole-addon] Persisted dirs:"
echo "  /etc/pihole    -> ${ETC_PIHOLE}"
echo "  /etc/dnsmasq.d -> ${ETC_DNSMASQ}"
echo "[pihole-addon] TZ=${TZ:-unset} DNSMASQ_LISTENING=${DNSMASQ_LISTENING:-unset} ServerIP=${ServerIP:-unset}"
echo "[pihole-addon] Wildcards written (${wild_count}) to ${WILDCARD_FILE}:"
sed -n '1,200p' "$WILDCARD_FILE" || true

# --------- handoff to upstream init (s6-overlay v2/v3) ----------
if [ -x /s6-init ]; then
  exec /s6-init
elif [ -x /init ]; then
  exec /init
else
  echo "[pihole-addon] WARNING: No s6 init binary found. Starting services directly…"
  command -v pihole >/dev/null 2>&1 && pihole -g || true
  command -v pihole-FTL >/dev/null 2>&1 && pihole-FTL no-daemon &
  command -v lighttpd   >/dev/null 2>&1 && exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
  echo "[pihole-addon] No server binaries found. Idling for debug."
  exec tail -f /dev/null
fi
