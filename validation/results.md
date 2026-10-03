# Validation Results

Counts come from the lab attacks described in the main README.

## Splunk alerts (SPL)
Total triggered alerts: **42** (Triggered Alerts page).

## Brute force tuning
| Version | Threshold | Result rows (same window) |
|---------|-----------|---------------------------|
| v1 | count >= 1 | 9 |
| Tuned | count >= 5 per account per 5 min | 2 |

78% fewer rows, including mistyped-password attempts. Kept: Administrator, fakeuser. Dropped: 7 single typos.

## Portable rules
| Rule | Engine | Hits on attack data | False hits on benign data | Notes / fixes |
|------|--------|--------------------|---------------------------|---------------|
| ps_suspicious_commandline.yml | Sigma -> Splunk | 3 | 0 | Converts cleanly |
| failed_logon_burst.yml | Sigma -> Splunk | n/a | n/a | Grouped by TargetUserName, events use Account_Name. Fixed in rule |
| port_scan_many_ports.yml | Sigma -> Splunk | n/a | n/a | No EventCode filter. Added EventID 3 |
| SID 1000001 | Snort | 1,412 raw alerts (2 scans) | 0 during Hydra | Report 2 scans detected |
| SID 1000002 | Snort | 8 during Hydra | 0 during Nmap | |
| ps_lab_detections.yar (3 rules) | YARA | 3 of 3 files | 0 (benign.txt) | |

## Time to detect
| Attack | Alert mode | Launched | Alert | Delta |
|--------|-----------|----------|-------|-------|
| Nmap scan | Real-time | 14:22:05 | 14:22:19 | 14 s |
| PowerShell cradle | Real-time | 14:31:40 | 14:31:49 | 9 s |
| Hydra, tuned alert | Scheduled, 5 min | 14:40:10 | 14:44:22 | 4 min 12 s |
| Hydra, v1 alert | Scheduled, hourly | 14:40:10 | 15:00:03 | 19 min 53 s |

## Findings and fixes
- Brute force v1 (count >= 1) alerts on every mistyped password. Tuned to 5 per account in 5 minutes.
- The Sigma brute force rule used TargetUserName but the Splunk events expose Account_Name. Changed the group-by field.
- The Sigma port scan rule matched any TCP event with no EventCode filter. Added EventID 3 (Sysmon network connection).
- Snort SID 1000001 fires per packet burst, so 1,412 alerts represent 2 scans. Count scans, not raw alerts.
- Hourly scheduled alerts delay detection by up to 60 minutes. The 5-minute schedule caps it near 5.
