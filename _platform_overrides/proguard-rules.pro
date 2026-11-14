# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
# Local notifications (Gson reflection)
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
-keep class com.google.gson.** { *; }
# Alarm package
-keep class com.gdelataillade.alarm.** { *; }
# Secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
# Google Play Core (deferred components, not used)
-dontwarn com.google.android.play.core.**
