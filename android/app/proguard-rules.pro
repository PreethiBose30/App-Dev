# ML Kit text recognition ships optional script modules (Chinese, Devanagari,
# Japanese, Korean) that this app does not include. R8 would otherwise fail
# the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# flutter_local_notifications stores scheduled reminders as JSON via Gson.
# R8 strips the generic type info Gson reads, which crashes scheduling in
# release builds ("Missing type parameter").
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
