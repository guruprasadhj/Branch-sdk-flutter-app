import 'dart:async';
import 'dart:io';

import 'package:branchtask/screens/home_screen.dart';
import 'package:branchtask/screens/product_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:uuid/uuid.dart';

import 'custom_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBranchSdk.init().then((value) {
    FlutterBranchSdk.validateSDKIntegration();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();

  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';

  @override
  void initState() {
    super.initState();

    listenDynamicLinks();

    initDeepLinkData();

    //requestATTTracking();
  }


  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        print(
            '------------------------------------Link clicked----------------------------------------------');
        print('Title: ${data['\$og_title']}');
        print('Custom string: ${data['custom_string']}');
        print('Custom number: ${data['custom_number']}');
        print('Custom bool: ${data['custom_bool']}');
        print('Custom date: ${data['custom_date_created']}');
        print('Custom list number: ${data['custom_list_number']}');
        print(
            '------------------------------------------------------------------------------------------------');
        showSnackBar(
            message:
            'Link clicked: Custom string - ${data['custom_string']} - Date: ${data['custom_date_created'] ?? ''}',
            duration: 10);
      }
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    });
  }

  void initDeepLinkData() {
    final DateTime today = DateTime.now();
    String dateString =
        '${today.year}-${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';

    metadata = BranchContentMetaData();


    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
        title: 'Flutter Branch Plugin - $dateString',
        imageUrl: imageURL,
        contentDescription: 'Flutter Branch Description - $dateString',
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);
    lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three']);

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
      ..transactionID = '12344555'
      ..alias = 'StandardEventAlias'
      ..currency = BranchCurrencyType.BRL
      ..revenue = 1.5
      ..shipping = 10.2
      ..tax = 12.3
      ..coupon = 'test_coupon'
      ..affiliation = 'test_affiliation'
      ..eventDescription = 'Event_description'
      ..searchQuery = 'item 123'
      ..adType = BranchEventAdType.BANNER
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..alias = 'CustomEventAlias'
      ..addCustomData(
          'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
      ..addCustomData(
          'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
  }

  void showSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

   void validSdkIntegration() {
    if (kIsWeb) {
      showSnackBar(
          message: 'validateSDKIntegration() not available in Flutter Web');
      return;
    }

    FlutterBranchSdk.validateSDKIntegration();
    if (Platform.isAndroid) {
      showSnackBar(message: 'Check messages in run log or logcat');
    }
  }

  void enableTracking() {
    FlutterBranchSdk.disableTracking(false);
    showSnackBar(message: 'Tracking enabled');
  }

  void disableTracking() {
    FlutterBranchSdk.disableTracking(true);
    showSnackBar(message: 'Tracking disabled');
  }

  void identifyUser() async {
    final isUserIdentified = await FlutterBranchSdk.isUserIdentified();
    if (isUserIdentified) {
      showSnackBar(message: 'User logged in');
      return;
    }
    final userId = const Uuid().v4();
    FlutterBranchSdk.setIdentity(userId);
    showSnackBar(message: 'User identified: $userId');
  }

  void userLogout() async {
    final isUserIdentified = await FlutterBranchSdk.isUserIdentified();
    if (!isUserIdentified) {
      showSnackBar(message: 'No users logged in');
      return;
    }
    FlutterBranchSdk.logout();
    showSnackBar(message: 'User logout');
  }

  void registerView() {
    FlutterBranchSdk.registerView(buo: buo);
    showSnackBar(message: 'Event Registered');
  }

  void trackContent() {
    FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventStandard);

    FlutterBranchSdk.trackContent(buo: [buo], branchEvent: eventCustom);

    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventStandard);

    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom);

    showSnackBar(message: 'Tracked content');
  }

  void getFirstParameters() async {
    Map<dynamic, dynamic> params =
    await FlutterBranchSdk.getFirstReferringParams();
    controllerData.sink.add(params.toString());
    showSnackBar(message: 'First Parameters recovered');
  }

  void getLastParameters() async {
    Map<dynamic, dynamic> params =
    await FlutterBranchSdk.getLatestReferringParams();
    controllerData.sink.add(params.toString());
    showSnackBar(message: 'Last Parameters recovered');
  }

  void getLastAttributed() async {
    BranchResponse response =
    await FlutterBranchSdk.getLastAttributedTouchData();
    if (response.success) {
      controllerData.sink.add(response.result.toString());
      showSnackBar(message: 'Last Attributed TouchData recovered');
    } else {
      showSnackBar(
          message:
          'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void listOnSearch() async {
    if (kIsWeb) {
      showSnackBar(message: 'listOnSearch() not available in Flutter Web');
      return;
    }
    //Buo without Link Properties
    bool success = await FlutterBranchSdk.listOnSearch(buo: buo);

    //Buo with Link Properties
    success = await FlutterBranchSdk.listOnSearch(buo: buo, linkProperties: lp);

    if (success) {
      showSnackBar(message: 'Listed on Search');
    }
  }

  void removeFromSearch() async {
    if (kIsWeb) {
      showSnackBar(message: 'removeFromSearch() not available in Flutter Web');
      return;
    }
    bool success = await FlutterBranchSdk.removeFromSearch(buo: buo);
    success =
    await FlutterBranchSdk.removeFromSearch(buo: buo, linkProperties: lp);
    if (success) {
      showSnackBar(message: 'Removed from Search');
    }
  }

  void generateLink(BuildContext context) async {
    initDeepLinkData();
    BranchResponse response =
    await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      if (context.mounted) {
        showGeneratedLink(context, response.result);
      }
    } else {
      showSnackBar(
          message: 'Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  void generateQrCode(
      BuildContext context,
      ) async {
    /*
    BranchResponse responseQrCodeData = await FlutterBranchSdk.getQRCodeAsData(
        buo: buo!,
        linkProperties: lp,
        qrCode: BranchQrCode(
            primaryColor: Colors.black,
            //backgroundColor: const Color(0xff443a49), //Hex Color
            centerLogoUrl: imageURL,
            backgroundColor: Colors.white,
            imageFormat: BranchImageFormat.PNG));
    if (responseQrCodeData.success) {
      print(responseQrCodeData.result);
    } else {
      print(
          'Error : ${responseQrCodeData.errorCode} - ${responseQrCodeData.errorMessage}');
    }
     */
    initDeepLinkData();
    BranchResponse responseQrCodeImage =
    await FlutterBranchSdk.getQRCodeAsImage(
        buo: buo,
        linkProperties: lp,
        qrCode: BranchQrCode(
            primaryColor: Colors.black,
            //primaryColor: const Color(0xff443a49), //Hex colors
            centerLogoUrl: imageURL,
            backgroundColor: Colors.white,
            imageFormat: BranchImageFormat.PNG));
    if (responseQrCodeImage.success) {
      if (context.mounted) {
        showQrCode(context, responseQrCodeImage.result);
      }
    } else {
      showSnackBar(
          message:
          'Error : ${responseQrCodeImage.errorCode} - ${responseQrCodeImage.errorMessage}');
    }
  }

  void showGeneratedLink(BuildContext context, String url) async {
    initDeepLinkData();
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 200,
            child: Column(
              children: <Widget>[
                const Center(
                    child: Text(
                      'Link created',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Text(url,
                    maxLines: 1,
                    style: const TextStyle(overflow: TextOverflow.ellipsis)),
                const SizedBox(
                  height: 10,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: CustomButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          Navigator.pop(this.context);
                        }
                      },
                      child: const Center(child: Text('Copy link'))),
                ),
                const SizedBox(
                  height: 10,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: CustomButton(
                      onPressed: () {
                        FlutterBranchSdk.handleDeepLink(url);
                        Navigator.pop(this.context);
                      },
                      child: const Center(child: Text('Handle deep link'))),
                ),
              ],
            ),
          );
        });
  }

  void showQrCode(BuildContext context, Image image) async {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 370,
            child: Column(
              children: <Widget>[
                const Center(
                    child: Text(
                      'Qr Code',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Image(
                  image: image.image,
                  height: 250,
                  width: 250,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: CustomButton(
                      onPressed: () => Navigator.pop(this.context),
                      child: const Center(child: Text('Close'))),
                ),
              ],
            ),
          );
        });
  }

  void shareLink() async {
    initDeepLinkData();
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      showSnackBar(message: 'showShareSheet Success', duration: 5);
    } else {
      showSnackBar(
          message:
          'showShareSheet Error: ${response.errorCode} - ${response.errorMessage}',
          duration: 5);
    }
  }

  void shareWithLPLinkMetadata() async {
    /// Create a BranchShareLink instance with a BranchUniversalObject and LinkProperties.
    /// Set the BranchShareLink's LPLinkMetadata by using the addLPLinkMetadata() function.
    ///Present the BranchShareLink's Share Sheet.

    ///Load icon from Assets
    final iconData = (await rootBundle.load('assets/images/branch_logo.jpeg'))
        .buffer
        .asUint8List();

    /*
    ///Load icon from Web
    final iconData =
        (await NetworkAssetBundle(Uri.parse(imageURL)).load(imageURL))
            .buffer
            .asUint8List();
    */
    initDeepLinkData();
    FlutterBranchSdk.shareWithLPLinkMetadata(
        buo: buo,
        linkProperties: lp,
        title: "Share With LPLinkMetadata",
        icon: iconData);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Branch SDK Example'),
        ),
        body: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                StreamBuilder<String>(
                  stream: controllerInitSession.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: <Widget>[
                          Center(
                              child: Text(
                                snapshot.data!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ))
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                CustomButton(
                  onPressed: validSdkIntegration,
                  child: const Text('Validate SDK Integration'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: enableTracking,
                        child: const Text('Enable tracking'),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: disableTracking,
                        child: const Text('Disable tracking'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: identifyUser,
                        child: const Text('Identify user'),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: userLogout,
                        child: const Text('User logout'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: registerView,
                        child: const Text('Register view'),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: trackContent,
                        child: const Text('Track content'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: getFirstParameters,
                        child: const Text('Get First Parameters',
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: getLastParameters,
                        child: const Text('Get Last Parameters',
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: getLastAttributed,
                        child: const Text('Get Last Attributed',
                            textAlign: TextAlign.center),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: listOnSearch,
                        child: const Text('List on Search',
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: removeFromSearch,
                        child: const Text('Remove from Search',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () => generateLink(context),
                        child: const Text('Generate Link',
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => generateQrCode(context),
                        child: const Text('Generate QrCode',
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: (CustomButton(
                          onPressed: shareLink,
                          child:
                          const Text('Share Link', textAlign: TextAlign.center),
                        ))),
                    Expanded(
                        child: CustomButton(
                          onPressed: shareWithLPLinkMetadata,
                          child: const Text('Share Link with LPLinkMetadata',
                              textAlign: TextAlign.center),
                        ))
                  ],
                ),
                const Divider(),
                const Center(
                  child: Text(
                    'Data',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                StreamBuilder<String>(
                  stream: controllerData.stream,
                  initialData: null,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children: [
                          Center(child: Text(snapshot.data!)),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controllerData.close();
    controllerInitSession.close();
    streamSubscription?.cancel();
  }
}
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
