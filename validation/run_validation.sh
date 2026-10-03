#!/bin/bash
# Runs the portable validation steps and saves real output to validation/output/.
# Run from the repo root on Kali (needs: yara, and sigma-cli with the splunk plugin).
# Snort and Splunk steps are manual; instructions are printed at the end.
set -u
OUT=validation/output
mkdir -p "$OUT"

echo "== YARA =="
if command -v yara >/dev/null; then
  ( cd detection-rules/yara && bash test_yara.sh ) 2>&1 | tee "$OUT/yara_results.txt"
else
  echo "yara not installed: sudo apt install yara" | tee "$OUT/yara_results.txt"
fi

echo "== Sigma -> Splunk SPL =="
if command -v sigma >/dev/null; then
  for f in detection-rules/sigma/*.yml; do
    n=$(basename "$f" .yml)
    sigma convert -t splunk "$f" > "$OUT/sigma_${n}.spl" 2> "$OUT/sigma_${n}.err" \
      && echo "converted $n" || echo "FAILED $n (see $OUT/sigma_${n}.err)"
  done
else
  echo "sigma-cli not installed: pip install sigma-cli && sigma plugin install splunk"
fi

cat <<'MSG'

== Manual steps (save the evidence) ==
1. Splunk: paste each validation/output/sigma_*.spl into Search over the attack time range.
   Screenshot the results into validation/screenshots/ and record the hit counts in validation/results.md.
   If a rule returns 0 hits, check field names in your events and fix the rule. Note the fix in results.md.
2. Snort: sudo snort -c /etc/snort/snort.lua -R detection-rules/snort/lab_scan_bruteforce.rules -i eth0 -A alert_fast | tee validation/output/snort_alert_fast.txt
   Then run the Nmap scan and Hydra attack from the README against the lab.
3. Splunk Triggered Alerts page: screenshot to validation/screenshots/triggered_alerts.png.
MSG
