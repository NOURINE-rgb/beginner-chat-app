import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class HomePage {
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountFile = File('config/service_account.json');
    final serviceAccountJson = json.decode(serviceAccountFile.readAsStringSync());
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  static Future<void> sendFCMMessage(String title, String msg) async {
    final String serverKey = await getAccessToken(); // Your FCM server key
    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/flutter-chat-app-e5547/messages:send';
    final currentFCMToken = await FirebaseMessaging.instance.getToken();
    print("fcmkey : $currentFCMToken");
    final Map<String, dynamic> message = {
      'message': {
        'token':
            currentFCMToken, // Token of the device you want to send the message to
        'notification': {
          'body': msg,
          'title': title
        },
        'data': {
          'current_user_fcm_token':
              currentFCMToken, // Include the current user's FCM token in data payload
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
      print("*********************** sent the notification");
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}
