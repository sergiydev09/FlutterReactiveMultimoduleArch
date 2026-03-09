# Flutter / Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Retrofit (generated code)
-keepattributes Signature
-keepattributes Exceptions
-keepattributes *Annotation*

# JSON serialization — keep model classes with @JsonSerializable
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Play Integrity
-keep class com.google.android.play.core.integrity.** { *; }

# safe_device / flutter_jailbreak_detection
-keep class com.scottyab.rootbeer.** { *; }

# Crypto (certificate pinning)
-keep class org.bouncycastle.** { *; }
