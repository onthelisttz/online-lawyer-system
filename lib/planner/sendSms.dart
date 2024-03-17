import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class SendSms extends StatefulWidget {
  const SendSms({super.key});

  @override
  State<SendSms> createState() => _SendSmsState();
}

class _SendSmsState extends State<SendSms> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      // telephony.listenIncomingSms(
      //     onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutlinedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color(0xFF009999),
                  ),
                  side: MaterialStateProperty.all(BorderSide(
                    color: Color.fromARGB(255, 177, 237, 237),
                  )),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ))),
              onPressed: () {
                sendMessage();
              },
              child: Text(
                ' send sms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              )),
        ),
      ),
    );
  }

  sendMessage() {
    final SmsSendStatusListener listener = (SendStatus status) {
      // Handle the status
      print(status);
    };

    try {
      telephony.sendSms(
        to: "255743451357",
        message: "May the force be with you!",
        statusListener: listener,
      );
    } catch (e) {
      print("Error sending SMS: $e");
      // Handle the error
    }
  }
}
