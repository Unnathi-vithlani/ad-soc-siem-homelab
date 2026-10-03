# Output

Drop raw command output here:

- `yara_results.txt` (YARA scan of the attack and benign files)
- `snort_alert_fast.txt` (Snort alerts during Nmap and Hydra)
- `sigma_*.spl` and `sigma_*.err` (Sigma rules converted to Splunk SPL)

`bash validation/run_validation.sh` creates the YARA and Sigma files for you.
