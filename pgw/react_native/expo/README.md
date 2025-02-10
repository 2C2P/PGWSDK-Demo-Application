# Welcome to your Expo app 👋

This is an [Expo](https://expo.dev) project created with [`create-expo-app`](https://www.npmjs.com/package/create-expo-app).

## Get started

1. Install dependencies.

   ```bash
   npx expo install @expo/config-plugins expo-build-properties @2c2p/pgw-sdk-react-native
   ```

2. Download the PGW SDK iOS frameworks.

   ```bash
   cd node_modules/@2c2p/pgw-sdk-react-native && yarn run ios-frameworks && cd ../../..
   ```

3. Update app.json. [Reference](./app.json)

4. Add plugins files. [Reference](./plugins/)

5. Pre-build the android and iOS projects.

   ```bash
   npx expo prebuild --clean
   ```

6. Verify all the app.json and plugin files configuration applied and generated to iOS and android project.

7. Run iOS / Android app.
   
   ```bash
   npx expo run:ios or npx expo run:android
   ```


In the output, you'll find options to open the app in a:

- [development build](https://docs.expo.dev/develop/development-builds/introduction/)
- [Android emulator](https://docs.expo.dev/workflow/android-studio-emulator/)
- [iOS simulator](https://docs.expo.dev/workflow/ios-simulator/)
- [Expo Go](https://expo.dev/go), a limited sandbox for trying out app development with Expo

## Reference

- [Link](https://developer.2c2p.com/docs/sdk-download-sdk-react-native)