# Validation

This folder holds the evidence that each rule was run, not just written.

## How to use
1. Run `bash validation/run_validation.sh` from the repo root (Kali).
2. Follow the manual steps it prints (Splunk searches, Snort run, screenshots).
3. Fill in `results.md` with your real numbers.
4. Update the status table in `detection-rules/README.md`.

## What goes where
| Path | Contents |
|------|----------|
| `output/` | Raw command output: YARA results, converted SPL, Snort alerts |
| `screenshots/` | Splunk searches and Triggered Alerts page |
| `results.md` | Counts and findings, including rules that needed fixing |

Only record results you actually observed.
