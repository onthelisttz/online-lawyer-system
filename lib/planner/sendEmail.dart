import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SendMailer extends StatefulWidget {
  const SendMailer({super.key});

  @override
  State<SendMailer> createState() => _SendMailerState();
}

class _SendMailerState extends State<SendMailer> {
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
                ' Request',
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

  sendMessage() async {
    // Note that using a username and password for gmail only works if
    // you have two-factor authentication enabled and created an App password.
    // Search for "gmail app password 2fa"
    // The alternative is to use oauth.
    String username = 'msigwamb@gmail.com';
    String password = 'dueftnrbaeqsopfa';

    final smtpServer = gmail(username, password);

    // Create our message.
    final message = Message()
      ..from = Address(username, 'Online lawyer  management system')
      ..recipients.add('onthelisttz@gmail.com')
      // ..ccRecipients.addAll([
      //   'onthelisttz@gmail.com',
      // ])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Booking Reminder :: 😀 :: ${DateTime.now()}'
      ..text =
          'you are been notified that your schedule with juma will start soon'
      ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
