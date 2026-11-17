# App sources and terms

This test package contains the wrapper and guide only. It does not redistribute the five apps' installers, copy their branding, or claim endorsement by their publishers. Any future paid offer would be for setup/support, not ownership of these free-to-obtain apps.

| App | Exact WinGet ID | Publisher terms/licence reference |
|---|---|---|
| Chrome | Google.Chrome | https://www.google.com/chrome/terms/ and https://policies.google.com/terms |
| VLC | VideoLAN.VLC | WinGet reports GPL-2.0; https://code.videolan.org/videolan/vlc/-/blob/HEAD/COPYING |
| 7-Zip | 7zip.7zip | https://7-zip.org/license.txt — LGPL with additional component terms |
| Zoom Workplace | Zoom.Zoom | https://www.zoom.com/en/trust/terms/ |
| Notepad++ | Notepad++.Notepad++ | https://github.com/notepad-plus-plus/notepad-plus-plus/blob/HEAD/LICENSE — GPL-3.0-or-later reported by WinGet |

References were taken from the real WinGet metadata and publisher pages checked on 17 November 2026. The VLC licence page could not be fetched through the research tool; its licence classification remains metadata evidence. This is not a complete legal review or a transfer of publisher rights.

Read applicable terms before running the installer. The wrapper uses WinGet's package/source agreement acceptance flags during installation. A preview installs nothing and does not accept package agreements. Zoom service usage may require a separate account and some features may be paid; the wrapper does not create accounts, purchase services, or enter credentials.

In the Windows 11 ARM staged-download check, four installers had valid Authenticode signatures. The 7-Zip installer was unsigned; its download hash was verified by WinGet. Microsoft Defender reported no matching detections in the staged downloads. Hashes, signatures and an antivirus result reduce risk but do not prove software is harmless. Downloaded files are not included here.
