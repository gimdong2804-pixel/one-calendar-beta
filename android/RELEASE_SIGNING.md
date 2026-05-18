# Android Release Signing

One Calendar Beta release APKs are signed with a fixed release keystore.

Required local files, not committed to git:

- `C:\Users\gimdo\.android\one_calendar_beta_release.jks`
- `android\key.properties`

Keep both files backed up together. If either file is lost, future APKs cannot update apps that were installed from Beta 22 or later without uninstalling first.

A local backup copy was created outside git at:

```text
C:\Users\gimdo\Desktop\OneCalendar-signing-backup-DO-NOT-DELETE
```

Current release certificate SHA-256:

```text
A8:A3:0A:8C:E8:DA:7F:B5:11:D9:F1:38:68:63:65:F8:D4:4C:F9:CB:12:93:38:6B:6C:0D:32:B6:27:13:5C:65
```

To verify an APK:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\35.0.0\apksigner.bat" verify --print-certs "beta\OneCalendar-Beta22.apk"
```
