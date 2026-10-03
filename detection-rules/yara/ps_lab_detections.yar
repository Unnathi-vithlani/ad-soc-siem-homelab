/*
  YARA rules for suspicious PowerShell command lines
  Source lab: ad-soc-siem-homelab (Splunk alert "Suspicious PowerShell Execution")
  Author: Unnathi Vithlani
  Use: scan saved scripts, command line exports, or Sysmon Event ID 1 text exports
*/

rule PS_Download_Cradle_IEX
{
    meta:
        description = "PowerShell download cradle: IEX with Net.WebClient and DownloadString or DownloadFile"
        author = "Unnathi Vithlani"
        date = "2026-10-03"
        mitre_attack = "T1059.001"
        lab_alert = "Suspicious PowerShell Execution"

    strings:
        $iex1 = "IEX" ascii wide nocase fullword
        $iex2 = "Invoke-Expression" ascii wide nocase
        $web  = "Net.WebClient" ascii wide nocase
        $dl1  = "DownloadString" ascii wide nocase
        $dl2  = "DownloadFile" ascii wide nocase

    condition:
        1 of ($iex*) and $web and 1 of ($dl*)
}

rule PS_Encoded_Command
{
    meta:
        description = "PowerShell launched with an encoded command argument"
        author = "Unnathi Vithlani"
        date = "2026-10-03"
        mitre_attack = "T1059.001"
        lab_alert = "Suspicious PowerShell Execution"

    strings:
        $ps   = "powershell" ascii wide nocase
        $enc1 = "-EncodedCommand" ascii wide nocase
        $enc2 = "-enc " ascii wide nocase

    condition:
        $ps and 1 of ($enc*)
}

rule PS_ExecutionPolicy_Bypass
{
    meta:
        description = "PowerShell launched with the execution policy set to Bypass"
        author = "Unnathi Vithlani"
        date = "2026-10-03"
        mitre_attack = "T1059.001"
        lab_alert = "Suspicious PowerShell Execution"

    strings:
        $ps  = "powershell" ascii wide nocase
        $bp1 = "-ExecutionPolicy Bypass" ascii wide nocase
        $bp2 = "-ep bypass" ascii wide nocase
        $bp3 = "-exec bypass" ascii wide nocase

    condition:
        $ps and 1 of ($bp*)
}
