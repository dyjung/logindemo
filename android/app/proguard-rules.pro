# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Moshi adapters
-keep class com.dyjung.logindemo.data.dto.** { *; }

# Keep Hilt
-keepclasseswithmembers class * {
    @dagger.hilt.* <methods>;
}

# Keep Retrofit
-keepattributes Signature
-keepattributes Exceptions
