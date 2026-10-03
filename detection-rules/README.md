# 🛡️ Detection Rules — Sigma, Snort & YARA

Portable versions of the detections built in this lab. Each rule mirrors an alert that fired in the Splunk environment (see the main [README](../README.md) and `screenshots/`), rewritten in a vendor-neutral format so it can be reused outside Splunk.

![Sigma](https://img.shields.io/badge/Sigma-3%20rules-blue)
![Snort](https://img.shields.io/badge/Snort-2%20rules-orange)
![YARA](https://img.shields.io/badge/YARA-3%20rules-red)
![MITRE](https://img.shields.io/badge/MITRE%20ATT%26CK-T1046%20%7C%20T1110%20%7C%20T1059.001-purple)

---

## 📂 Layout

```
detection-rules/
├── sigma/
│   ├── port_scan_many_ports.yml
│   ├── failed_logon_burst.yml
│   └── ps_suspicious_commandline.yml
├── snort/
│   └── lab_scan_bruteforce.rules
└── yara/
    ├── ps_lab_detections.yar
    └── test_yara.sh
```

---

## 🗺️ Rule Map

| Rule | Format | Lab alert it mirrors | MITRE ATT&CK | Data source |
|------|--------|----------------------|--------------|-------------|
| `port_scan_many_ports.yml` | Sigma (correlation) | Port Scan Detected | T1046 Network Service Discovery | Sysmon Event ID 3 |
| `failed_logon_burst.yml` | Sigma (correlation) | Brute Force Attempt | T1110 Brute Force | Security Event ID 4625 |
| `ps_suspicious_commandline.yml` | Sigma | Suspicious PowerShell Execution | T1059.001 PowerShell | Sysmon Event ID 1 |
| `lab_scan_bruteforce.rules` | Snort | Port scan and RDP brute force (SIDs 1000001, 1000002) | T1046, T1110 | Network traffic, 192.168.100.0/24 |
| `ps_lab_detections.yar` | YARA | Suspicious PowerShell Execution | T1059.001 | Saved scripts, command line exports |

---

## 🔎 What Each Rule Detects

**Sigma**
- **Port scan:** one source IP contacts more than 10 distinct destination ports within 1 minute.
- **Failed logon burst:** 5 or more failed logons (4625) for the same account within 5 minutes.
- **Suspicious PowerShell:** `powershell.exe` or `pwsh.exe` run with `-ExecutionPolicy Bypass`, `-EncodedCommand`, `IEX`, `Net.WebClient` or `DownloadString`.

**Snort**
- **SID 1000001:** 20 or more SYN packets from one source within 5 seconds (port scan).
- **SID 1000002:** 5 or more SYN packets from one source to port 3389 within 60 seconds (RDP brute force).

**YARA**
- `PS_Download_Cradle_IEX`: IEX plus `Net.WebClient` plus `DownloadString` or `DownloadFile`.
- `PS_Encoded_Command`: PowerShell with an encoded command argument.
- `PS_ExecutionPolicy_Bypass`: PowerShell with the execution policy set to Bypass.

---

## ✅ Validation Status

Summary of what has been tested:

| Layer | Status |
|-------|--------|
| Lab attacks (Nmap scan, failed logons, PowerShell commands) | ✅ Executed in the lab |
| Original Splunk alerts | ✅ Fired and documented (see main README and `screenshots/`) |
| Sigma rules run in their own engine | ✅ Tested |
| Snort rules loaded and run in Snort | ✅ Tested |
| YARA rules scanned against samples | ✅ Tested (script included below) |

Each rule was tested in its own engine against the lab attack activity. The commands used to reproduce the tests are in the next section.

---

## 🧪 How to Test

**YARA** (on Kali):

```bash
sudo apt install yara
cd detection-rules/yara
bash test_yara.sh
```

Expected: the three attack samples each match one rule, and the benign sample matches nothing.

**Sigma** (convert to Splunk SPL):

```bash
pip install sigma-cli
sigma plugin install splunk
sigma convert -t splunk detection-rules/sigma/ps_suspicious_commandline.yml
```

Run the generated search in Splunk against the lab data. The two correlation rules need a recent `sigma-cli` and a backend that supports correlations.

**Snort:**

```bash
sudo snort -c /etc/snort/snort.lua -R detection-rules/snort/lab_scan_bruteforce.rules -i eth0 -A alert_fast
```

Then run an Nmap SYN scan against 192.168.100.0/24 from Kali and check the alert output.

---

## ⚠️ Known Limitations

- Thresholds (10 ports per minute, 5 failures per 5 minutes) were tuned for this small lab. A production network would need different values and allow-listing for scanners and admin tools.
- YARA string matching can be evaded by obfuscation. It complements log-based detection and does not replace it.
- Snort rules assume the lab subnet `192.168.100.0/24` and need editing for other networks.

---

## 👤 Author

Unnathi Vithlani. Built as part of the [AD SOC SIEM Home Lab](../README.md).
