/*
 * Copyright (C) 2024 LEIDOS.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:ui';
import 'package:flutter/material.dart';

// Flutter Utils
import 'package:cybersecurity_its_app/utils/router_configuration.dart';
import 'package:cybersecurity_its_app/utils/login_info.dart';
import 'package:cybersecurity_its_app/utils/zoom_info.dart';

// Firebase Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

// State Management Providers
import 'package:provider/provider.dart';
import 'package:cybersecurity_its_app/providers/button_enabler_provider.dart';
import 'package:cybersecurity_its_app/providers/issue_checkbox_provider.dart';
import 'package:cybersecurity_its_app/providers/devices_provider.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'amplifyconfiguration.dart';

final LoginInfo _loginInfo = LoginInfo();
final ZoomInfo _zoomInfo = ZoomInfo();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

  await _configureAmplify();

  runApp(const AppProviders());
}

Future<void> _configureAmplify() async {

    // Add any Amplify plugins you want to use
    final authPlugin = AmplifyAuthCognito();
    final api = AmplifyAPI();
    //await Amplify.addPlugin(authPlugin);

    // You can use addPlugins if you are going to be adding multiple plugins
    await Amplify.addPlugins([authPlugin, api]);

    // Once Plugins are added, configure Amplify
    // Note: Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      safePrint("Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }
  }

/// Initializes all providers, before building the main app.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) =>
      MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => _zoomInfo),
            ChangeNotifierProvider(
                create: (_) => _loginInfo),
            ChangeNotifierProvider(
                create: (_) => ButtonEnabler()),
            ChangeNotifierProvider(
                create:(_) => IssueCheckboxList()),
            ChangeNotifierProvider(
                create: (_) => DevicesProvider()),
          ],
        child: MyApp(),
      );
}

class MyApp extends StatelessWidget {
  
  MyApp({super.key});

  bool runOnce = true;

  @override
    Widget build(BuildContext context) {

    /// Initialize Store and zoom level only on first build.
    if (runOnce){
      runOnce = false;
      Provider.of<ZoomInfo>(context).initZoomLevelStore();
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp.router(
        builder: (BuildContext context, Widget? child) {

          /// Get Current Media info, and multiply by user settings.
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
                textScaleFactor: data.textScaleFactor * Provider.of<ZoomInfo>(context).zoomLevel,
                boldText: true
            ),
            child: child!,
          );
        },
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: false,
        ),
      )
    );
  }
}

