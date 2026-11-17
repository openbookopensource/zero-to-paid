# Checked test candidate — not general customer release

Checked source: `208c2ffcbe485eb3914261afe834a42d968c6339`.

Passing Windows 11 ARM workflow: https://github.com/openbookopensource/zero-to-paid/actions/runs/44074340615

- Both workflow jobs succeeded: 16 simulated wrapper assertions and a real-app integration test.
- Real target: Windows 11 Enterprise, build 26200, ARM64.
- Chrome and 7-Zip were already present and remained untouched. VLC, Zoom and Notepad++ were installed, verified, skipped on repeat, then removed on undo. Independent checks confirmed the additions were absent and the original two apps remained.
- Ownership records exactly matched the additions, had no duplicates, and were removed after successful undo.
- Microsoft Defender antivirus and real-time protection were active before and after installation. All five staged installer downloads passed WinGet hash validation; four had valid Authenticode signatures, while 7-Zip was unsigned. Defender reported no matching detections in the staged downloads.
- Staged downloads are separate from the wrapper's later downloads. These checks do not guarantee absence of malware or prove the same staged bytes were executed.
- Source and package data scans completed without secret/personal-data findings after classifying public workflow IDs, Windows error codes and numeric digest substrings as false positives. No macros or third-party application binaries are bundled.

Remaining release checks: Windows 11 x64; interactive UAC and first launch; a person following only the guide; offline, low-disk and unusual-path behavior; executable PATH substitution and concurrent ledger changes; final support and publisher-terms review. No claim that these checks passed is made. Use only a disposable test PC/VM; do not use this candidate on your primary laptop.

Account/laptop safety: only project branches in the selected public repository were changed. Main was not merged. No owner-device install, account-security change, private credential collection, spending or customer outreach occurred. Standard hosted Windows runners are free for public repositories and job VMs are automatically decommissioned by GitHub after completion.

Provider documentation: https://docs.github.com/en/actions/reference/runners/github-hosted-runners and https://docs.github.com/en/actions/how-tos/manage-runners/github-hosted-runners/use-github-hosted-runners

Source review and next work: https://github.com/openbookopensource/zero-to-paid/pull/1
