# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# react-native-reanimated
-keep class com.swmansion.reanimated.** { *; }
-keep class com.facebook.react.turbomodule.** { *; }

# Add any project specific keep options here:

# @generated begin expo-build-properties - expo prebuild (DO NOT MODIFY)
#React Native
-keep class com.facebook.react.** { *; }
-keepnames class com.facebook.react.* { *; }
-keepnames interface com.facebook.react.* { *; }

#PGWReactNative
-keep class com.ccpp.pgw.sdk.reactnative.** { *; }
-keepnames class com.ccpp.pgw.sdk.reactnative.* { *; }
-keepnames interface com.ccpp.pgw.sdk.reactnative.* { *; }

#React Native Plugins
-keep class com.swmansion.rnscreens.** { *; }
-keepnames class com.swmansion.rnscreens.* { *; }
-keepnames interface com.swmansion.rnscreens.* { *; }
# @generated end expo-build-properties