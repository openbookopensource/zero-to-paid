# Goal record v1 — 17 November 2026

Owner request: lead project to completion and publication, then find customers. User selected 5 Apps and the openbookopensource GitHub account; delegated remaining product choices. Latest constraints: protect accounts and laptop first, mitigate malware and prompt injection, use OWASP recommendations.

Chosen first release: Chrome, VLC, 7-Zip, Zoom, Notepad++; Windows 11 personal PCs. Commercial hypothesis: charge for setup/support, never misrepresent free apps as owned software. No spending, credential collection, account security changes, laptop installation or customer outreach has occurred.

Finish line: downloadable package and plain-language guide, observed real Windows install/repeat/undo, preservation of existing apps, safe failure behavior, source/publisher checks, reviewed support route, then customer acquisition research.

Evidence: original archives contain identical installer copies. Static linter and strict source data scan passed after fixes (numeric Windows HRESULT explicitly classified as scanner false positive). Separate source reviewer found three additional record/preview issues; corrected before public branch update. First Windows Server 2025 simulated behavior run passed preview and inventory error checks but failed install-success assertion; diagnosis underway. These are not Windows 11 app installation tests.

Release state: source test candidate published in draft PR https://github.com/openbookopensource/zero-to-paid/pull/1 . Main untouched. Customer release blocked by failing behavior test and missing real Windows client evidence. No promise of background continuation.

Safety: OWASP mapping in OWASP-CONTROLS.md. Original uploads preserved. Git history provides source recovery. Disposable runner is the test surface. No autonomous customer agent ships in wrapper. Remaining batch/path and supply-chain risks documented; no claim of malware-free or OWASP-certified status.
