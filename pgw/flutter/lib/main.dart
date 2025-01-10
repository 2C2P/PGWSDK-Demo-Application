import 'package:flutter/material.dart';
import 'package:pgw_sdk_demo_application/apis/info_api.dart';
import 'package:pgw_sdk_demo_application/constants.dart';
import 'package:pgw_sdk_demo_application/scenes/home_screen.dart';

/*
 * Created by DavidBilly PK on 9/1/25.
 */
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {

  // Note: Important due to PGW SDK has to initialize before request APIs.
  await InfoApi.initialize().whenComplete(() {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        title: Constants.titleAppName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true
        ),
        home: const HomeScreen()
    );
  }
}
