import 'dart:async';


import 'package:branchtask/screens/product_screen.dart';
import 'package:branchtask/services/networking.dart';
import 'package:branchtask/widgets/custom_shopping_Card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;
  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';
  static final _networking = Networking();
  bool isLoading = false;

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
        if (data['key'] == "product_page") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductScreen(
                    imageURL: data['product_imageURl'],
                    title: data['product_title'],
                    description: data['product_description'],
                    actualPrice: data['custom_actual_price'],
                    discountedPrice: data['product_discount_price'],
                  )));
        }
      }
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    });
  }

  void initDeepLinkData() {
    final DateTime today = DateTime.now();
    String dateString =
        '${today.year}-${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';

    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_data', dateString);

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
        tags: ['one', 'two', 'three'])
      ..addControlParam(
          '\$android_url', 'https://flutter-branch-sdk.netlify.app/');
  }

  void cURLCustomEvent() async {
    Map<String, dynamic> body = {
      "name": "Testing With API cURL",
      "customer_event_alias": "my custom alias",
      "user_data": {
        "advertising_ids": {"oaid": "02ab41d3-7886-4f29-a606-fba4372e9fdc"},
        "os": "Android",
        "os_version": "25",
        "environment": "FULL_APP",
        "aaid": "abcdabcd-0123-0123-00f0-000000000000",
        "android_id": "a12300000000",
        "limit_ad_tracking": false,
        "developer_identity": "user123",
        "country": "US",
        "language": "en",
        "ip": "192.168.1.1",
        "local_ip": "192.168.1.2",
        "brand": "LGE",
        "app_version": "1.0.0",
        "model": "Nexus 5X",
        "screen_dpi": 420,
        "screen_height": 1794,
        "screen_width": 1080
      },
      "event_data": {
        "custom_param_1": "Parameter 1",
        "custom_param_2": "Parameter 2",
        "custom_param_3": "Parameter 3"
      },
      "custom_data": {"title": "branch Task"},
      "metadata": {},
      "branch_key": "key_live_fwaE1HspmSC8JH9SoDxcNcgntrbWKDtV"
    };

    var data = await _networking.postRequest(
        endpoint:
        '/v2/event/custom&branch_key=key_live_fwaE1HspmSC8JH9SoDxcNcgntrbWKDtV',
        body: body);
    print("Data:$data");
    Fluttertoast.showToast(msg: "custom event using cURL method Triggered\nOutput:$data");
  }
  createACustomEvent() {
    BranchEvent eventCustom = BranchEvent.customEvent('Custom_event_inbuilt');
    eventCustom.addCustomData('app_name', 'branch_task');
    eventCustom.addCustomData('Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
    FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom);
    Fluttertoast.showToast(msg: "custom event using inbuilt method Triggered");
  }
  @override
  void initState() {
    super.initState();
    listenDynamicLinks();
    initDeepLinkData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Branch Task"),
      ),
      body: isLoading?Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ):Container(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              CustomShoppingCard(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductScreen(
                              imageURL:
                              "https://images.unsplash.com/photo-1597671053855-1132c40cc1ce?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                              title: "Laptop Backpack",
                              description:
                              "Multi Functional Water Proof Anti Theft 15.6 inch Laptop Backpack",
                              actualPrice: "50",
                              discountedPrice: "28.99",
                            )));
                  },
                  title: "Laptop Backpack",
                  description:
                  "Multi Functional Water Proof Anti Theft 15.6 inch Laptop Backpack",
                  actualPrice: "50",
                  discountedPrice: "28.99",
                  imageURL:
                  "https://images.unsplash.com/photo-1597671053855-1132c40cc1ce?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
              CustomShoppingCard(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductScreen(
                            imageURL:
                            "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            title: "Gaming Keyboard",
                            description:
                            "65% BLUETOOTH + 2.4GHZ WIRELESS + WIRED RGB MECHANICAL KEYBOARD CREAM/GREY/ORANGE (RED SWITCH)",
                            actualPrice: "30",
                            discountedPrice: "18.99",
                          )));
                },
                title: "Gaming Keyboard",
                description:
                "65% BLUETOOTH + 2.4GHZ WIRELESS + WIRED RGB MECHANICAL KEYBOARD CREAM/GREY/ORANGE (RED SWITCH)",
                actualPrice: "30",
                discountedPrice: "18.99",
                imageURL:
                "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      createACustomEvent();
                    },
                    child: Text('Custom Trigger (Inbuilt)'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      cURLCustomEvent();
                    },
                    child: const Text('Custom Trigger(cURL)'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
//
// import 'package:branchtask/screens/product_screen.dart';
// import 'package:branchtask/widgets/custom_shopping_Card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
// import 'package:uuid/uuid.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   StreamSubscription<Map>? streamSubscription;
//   StreamController<String> controllerData = StreamController<String>();
//   StreamController<String> controllerInitSession = StreamController<String>();
//   BranchContentMetaData metadata = BranchContentMetaData();
//   BranchLinkProperties lp = BranchLinkProperties();
//   late BranchUniversalObject buo;
//   late BranchEvent eventStandard;
//   late BranchEvent eventCustom;
//   static const imageURL =
//       'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';
//
//   void listenDynamicLinks() async {
//     streamSubscription = FlutterBranchSdk.listSession().listen((data) async {
//       print('listenDynamicLinks - DeepLink Data: $data');
//       controllerData.sink.add((data.toString()));
//
//       if (data.containsKey('+clicked_branch_link') &&
//           data['+clicked_branch_link'] == true) {
//         print(
//             '------------------------------------Link clicked----------------------------------------------');
//         print('Title: ${data['\$og_title']}');
//         print('Custom string: ${data['custom_string']}');
//         print('Custom number: ${data['custom_number']}');
//         print('Custom bool: ${data['custom_bool']}');
//         print('Custom date: ${data['custom_date_created']}');
//         print('Custom list number: ${data['custom_list_number']}');
//         print(
//             '------------------------------------------------------------------------------------------------');
//         if (data['key'] == "product_page") {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => ProductScreen(
//                         imageURL: data['product_imageURl'],
//                         title: data['product_title'],
//                         description: data['product_description'],
//                         actualPrice: data['custom_actual_price'],
//                         discountedPrice: data['product_discount_price'],
//                       )));
//         }
//       }
//     }, onError: (error) {
//       print('listSession error: ${error.toString()}');
//     });
//   }
//
//   void initDeepLinkData() {
//     final DateTime today = DateTime.now();
//     String dateString =
//         '${today.year}-${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';
//
//     metadata = BranchContentMetaData()
//       ..addCustomMetadata('custom_string', 'abcd')
//       ..addCustomMetadata('custom_number', 12345)
//       ..addCustomMetadata('custom_bool', true)
//       ..addCustomMetadata('custom_list_number', [1, 2, 3, 4, 5])
//       ..addCustomMetadata('custom_list_string', ['a', 'b', 'c'])
//       ..addCustomMetadata('custom_date_created', dateString);
//
//     final canonicalIdentifier = const Uuid().v4();
//     buo = BranchUniversalObject(
//         canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
//         title: 'Flutter Branch Plugin - $dateString',
//         imageUrl: imageURL,
//         contentDescription: 'Flutter Branch Description - $dateString',
//         contentMetadata: metadata,
//         keywords: ['Plugin', 'Branch', 'Flutter'],
//         publiclyIndex: true,
//         locallyIndex: true,
//         expirationDateInMilliSec: DateTime.now()
//             .add(const Duration(days: 365))
//             .millisecondsSinceEpoch);
//     lp = BranchLinkProperties(
//         channel: 'share',
//         feature: 'sharing',
//         //parameter alias
//         //Instead of our standard encoded short url, you can specify the vanity alias.
//         // For example, instead of a random string of characters/integers, you can set the vanity alias as *.app.link/devonaustin.
//         // Aliases are enforced to be unique** and immutable per domain, and per link - they cannot be reused unless deleted.
//         //alias: 'https://branch.io' //define link url,
//         //alias: 'p/$id', //define link url,
//         stage: 'new share',
//         campaign: 'campaign',
//         tags: ['one', 'two', 'three'])
//       ..addControlParam('\$uri_redirect_mode', '1')
//       ..addControlParam('\$ios_nativelink', true)
//       ..addControlParam('\$match_duration', 7200)
//       ..addControlParam('\$always_deeplink', true)
//       ..addControlParam('\$android_redirect_timeout', 750)
//       ..addControlParam('referring_user_id', 'user_id') //;
//       ..addControlParam('\$ios_url', 'https://flutter-branch-sdk.netlify.app/')
//       ..addControlParam(
//           '\$android_url', 'https://flutter-branch-sdk.netlify.app/');
//
//     eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
//       //--optional Event data
//       ..transactionID = '12344555'
//       ..alias = 'StandardEventAlias'
//       ..currency = BranchCurrencyType.BRL
//       ..revenue = 1.5
//       ..shipping = 10.2
//       ..tax = 12.3
//       ..coupon = 'test_coupon'
//       ..affiliation = 'test_affiliation'
//       ..eventDescription = 'Event_description'
//       ..searchQuery = 'item 123'
//       ..adType = BranchEventAdType.BANNER
//       ..addCustomData(
//           'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
//       ..addCustomData(
//           'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
//
//     eventCustom = BranchEvent.customEvent('Custom_event')
//       ..alias = 'CustomEventAlias'
//       ..addCustomData(
//           'Custom_Event_Property_Key1', 'Custom_Event_Property_val1')
//       ..addCustomData(
//           'Custom_Event_Property_Key2', 'Custom_Event_Property_val2');
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     listenDynamicLinks();
//     initDeepLinkData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Branch Task"),
//       ),
//       body: Container(
//         alignment: Alignment.topCenter,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 height: 10,
//               ),
//               CustomShoppingCard(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ProductScreen(
//                                   imageURL:
//                                       "https://images.unsplash.com/photo-1597671053855-1132c40cc1ce?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
//                                   title: "Laptop Backpack",
//                                   description:
//                                       "Multi Functional Water Proof Anti Theft 15.6 inch Laptop Backpack",
//                                   actualPrice: "50",
//                                   discountedPrice: "28.99",
//                                 )));
//                   },
//                   title: "Laptop Backpack",
//                   description:
//                       "Multi Functional Water Proof Anti Theft 15.6 inch Laptop Backpack",
//                   actualPrice: "50",
//                   discountedPrice: "28.99",
//                   imageURL:
//                       "https://images.unsplash.com/photo-1597671053855-1132c40cc1ce?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
//               CustomShoppingCard(
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => ProductScreen(
//                                 imageURL:
//                                     "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
//                                 title: "Gaming Keyboard",
//                                 description:
//                                     "65% BLUETOOTH + 2.4GHZ WIRELESS + WIRED RGB MECHANICAL KEYBOARD CREAM/GREY/ORANGE (RED SWITCH)",
//                                 actualPrice: "30",
//                                 discountedPrice: "18.99",
//                               )));
//                 },
//                 title: "Gaming Keyboard",
//                 description:
//                     "65% BLUETOOTH + 2.4GHZ WIRELESS + WIRED RGB MECHANICAL KEYBOARD CREAM/GREY/ORANGE (RED SWITCH)",
//                 actualPrice: "30",
//                 discountedPrice: "18.99",
//                 imageURL:
//                     "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?q=80&w=2680&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
