import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // DeviceInfoPluginをインスタンス化
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  Widget build(BuildContext context) {
    Future<PackageInfo> _getPackageInfo() {
      return PackageInfo.fromPlatform();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Info"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("package_info",style: TextStyle(fontSize: 20),),
            FutureBuilder<PackageInfo>(
                future: _getPackageInfo(),
                builder: (BuildContext context,
                    AsyncSnapshot<PackageInfo> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('ERROR');
                  } else if (!snapshot.hasData) {
                    return const Text('Loading...');
                  }
                  final data = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('App Name: ${data.appName}'),
                      Text('Package Name: ${data.packageName}'),
                      Text('Version: ${data.version}'),
                      Text('Build Number: ${data.buildNumber}'),
                    ],
                  );
                }),
            Text("device_info",style: TextStyle(fontSize: 20),),
            buildFutureBuilder(),
          ],
        ),
      ),
    );
  }

  Widget buildFutureBuilder() {
    if (Platform.isIOS) {
      return FutureBuilder<IosDeviceInfo>(
        future: Future<IosDeviceInfo>(
          () async {
            // データ取得
            return (await deviceInfo.iosInfo);
          },
        ),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('model: ${snapShot.data!.model}'),
                Text('name: ${snapShot.data!.name}'),
                Text('systemVersion: ${snapShot.data!.systemVersion}'),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else if (Platform.isAndroid) {
      return FutureBuilder<AndroidDeviceInfo>(
        future: Future<AndroidDeviceInfo>(() async {
          // データ取得
          return (await deviceInfo.androidInfo);
        }),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('model: ${snapShot.data!.model}'),
                Text('device: ${snapShot.data!.device}'),
                Text('version.sdkInt: ${snapShot.data!.version.sdkInt}'),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
