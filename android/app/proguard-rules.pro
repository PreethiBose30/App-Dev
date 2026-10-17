# ML Kit text recognition ships optional script modules (Chinese, Devanagari,
# Japanese, Korean) that this app does not include. R8 would otherwise fail
# the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
