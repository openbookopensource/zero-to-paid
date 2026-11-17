# Five Apps — release candidate

Sets up Chrome, VLC, 7-Zip, Zoom and Notepad++ using Windows Package Manager. App binaries are downloaded by winget; they are not bundled or sold here. Each app has its own licence and service terms.

**Status: not yet approved for customer use.** Windows behavior tests and real installation checks must pass before a release is offered to customers.

The paid offer, if validated, is setup and support—not ownership of the five apps. No payment processing, customer tracking or background agent is included.

## Checks

- Static batch checker: `python tools/batch_lint.py package/Install-5-Apps.bat package/Uninstall-5-Apps.bat`.
- Windows simulated app checks: `powershell -NoProfile -File tests/test-windows.ps1` on a disposable Windows test machine with administrator rights. These mock winget and do not install the apps.
- Real installation: use a clean Windows 11 VM, snapshot it, run preview, install, repeat, then undo. Confirm app availability and preservation of a pre-existing app. Check network failure, cancelled UAC and low disk separately.

## Release bar

1. Preview changes nothing; install checks and reports each app.
2. Existing apps remain untouched; repeats do not duplicate records.
3. Undo removes only tracked additions and preserves records on failure.
4. A real Windows 11 user completes the guide; install, repeat and undo are observed.
5. A download URL, support route and app terms review are present.

Original uploads are preserved separately. Revert the project commit to undo source changes. A VM snapshot is the recommended recovery for testing; app uninstall cannot restore deleted preferences or user data.
