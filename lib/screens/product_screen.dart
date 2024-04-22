import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../custom_button.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen(
      {super.key,
      required this.imageURL,
      required this.title,
      required this.description,
      required this.actualPrice,
      required this.discountedPrice});

  final String imageURL;
  final String title;
  final String description;
  final String actualPrice;
  final String discountedPrice;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';

  void generateLink(BuildContext context, BranchUniversalObject branchUO,
      BranchLinkProperties branchLP) async {
    BranchResponse response = await FlutterBranchSdk.getShortUrl(
        buo: branchUO, linkProperties: branchLP);
    if (response.success) {
      print("Response:${response.result}");
      if (context.mounted) {
        showGeneratedLink(context, response.result);
      }
    } else {
      log("Error:${response.errorCode} - ${response.errorMessage}");
    }
  }

  void showGeneratedLink(BuildContext context, String url) async {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 250,
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
                      onPressed: () async {
                        // if (context.mounted) {
                        //   Navigator.pop(this.context);
                        // }

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
                        // if (context.mounted) {
                        //   Navigator.pop(this.context);
                        // }
                        if (responseQrCodeImage.success) {
                          if (context.mounted) {
                            showQrCode(context, responseQrCodeImage.result);
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Error");
                          // showSnackBar(
                          //   message:
                          //   'Error : ${responseQrCodeImage.errorCode} - ${responseQrCodeImage.errorMessage}');
                          log("Error ${responseQrCodeImage.errorCode} - ${responseQrCodeImage.errorMessage}");
                        }
                        Navigator.pop(this.context);
                      },
                      child: const Center(child: Text('Create QR Code'))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping"),
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width > 480
                ? 800
                : MediaQuery.of(context).size.width,
            // minHeight: MediaQuery.of(context).size.height>800?799:MediaQuery.of(context).size.height,
            // maxWidth: 480,
            // maxHeight: 800
          ),
          // width:MediaQuery.of(context).size.width,
          // height: ,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                            widget.imageURL,
                          ),
                          fit: BoxFit.cover),
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "${widget.title}",
                        // "Laptop Backpack",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "${widget.description}",
                        // "Multi Functional Water Proof Anti Theft 15.6 inch Laptop Backpack",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "\$${widget.actualPrice}",
                              style: TextStyle(
                                  color: Colors.black38,
                                  decoration: TextDecoration.lineThrough)),
                          TextSpan(
                              text: ' \$${widget.discountedPrice}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )),
                        ],
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
                            BranchEvent event = BranchEvent.standardEvent(BranchStandardEvent.PURCHASE);
                            event.transactionID    = "12344555";
                            event.currency         = BranchCurrencyType.USD;
                            event.revenue          = 1.5;
                            event.shipping         = 10.2;
                            event.tax              = 12.3;
                            event.coupon           = "test_coupon";
                            event.affiliation      = "test_affiliation";
                            event.eventDescription = "Event_description";
                            event.searchQuery      = "item 123";
                            event.addCustomData('Custom_Event_Property_Key1', 'Custom_Event_Property_val1');
                            event.addCustomData('Custom_Event_Property_Key2', 'Custom_Event_Property_val2');

                            FlutterBranchSdk.trackContentWithoutBuo( branchEvent: event);
                            // BranchEvent eventCustom = BranchEvent.customEvent('Custom_Event_Guru');
                            // eventCustom.addCustomData('Purchase_Item', '77777');
                            // eventCustom.addCustomData('Purchase_Name', 'Name_${widget.title}');
                            // FlutterBranchSdk.trackContentWithoutBuo(branchEvent: eventCustom);
                          },
                          child: Text('Buy Now'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 300,
                        height: 60,
                        child: OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            // backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            metadata = BranchContentMetaData()
                              ..addCustomMetadata('product_title', widget.title)
                              ..addCustomMetadata(
                                  'product_imageURl', widget.imageURL)
                              ..addCustomMetadata(
                                  'product_description', widget.description)
                              ..addCustomMetadata('product_discount_price',
                                  widget.discountedPrice)
                              ..addCustomMetadata(
                                  'custom_actual_price', widget.actualPrice)
                              ..addCustomMetadata('key', "product_page");
                            final canonicalIdentifier = const Uuid().v4();
                            buo = BranchUniversalObject(
                                canonicalIdentifier:
                                    'flutter/branch_$canonicalIdentifier',
                                title: 'Flutter Branch Plugin',
                                imageUrl:
                                    'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg',
                                contentDescription:
                                    'Flutter Branch Description',
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
                                campaign: 'normal_sharing_campaign',
                                tags: ['one', 'two', 'three']);
                            lp.addControlParam("\$uri_redirect_mode", 1);
                            return generateLink(context, buo, lp);
                          },
                          child: Text('Share'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar({required String message, int duration = 2}) {
    // scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }


}
