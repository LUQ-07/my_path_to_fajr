# ios/Runner/Info.plist - add inside <dict>

```xml
<key>UIBackgroundModes</key>
<array><string>audio</string><string>fetch</string></array>
<key>CFBundleLocalizations</key>
<array><string>ar</string><string>en</string><string>fr</string></array>
```
Alarm audio on iOS: keep the app allowed in Background App Refresh. iOS limits pending local notifications to 64, which is why the scheduler queues 60.
