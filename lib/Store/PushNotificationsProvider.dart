import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pet_shop/Config/config.dart';

class PushNotificationsProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _mensajesStreamController = StreamController<String>.broadcast();
  final String serverToken =
      'AAAAyllbuxU:APA91bFkC0SFUUggxHukBl-ntgYC_6gQ97mj46CYGc0cOeiAMf8D-MVqinDM1lYmsGn2xBKc6ZOIhHd_KaQJNyZeihu2WVrbjvtykxAh4ycu3qo6PGp4hU7hKr3gdnGAcCkEDRU1hHZx';

  Stream<String> get mensajeStream => _mensajesStreamController.stream;

  initNotifications() async {
    await _firebaseMessaging.requestNotificationPermissions(
        //const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
        );
    final token = await _firebaseMessaging.getToken();

    print("=== FCM Token ===");
    print(token);

    _firebaseMessaging.configure(
        onMessage: onMessage,
        onBackgroundMessage: Platform.isIOS ? null : onBackgroundMessage,
        onLaunch: onLaunch,
        onResume: onResume);
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    print("==== onMessage =====");
    final argumento = message['data'];
    print("Argumento: $argumento");
    _mensajesStreamController.sink.add(argumento);
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print("==== onLaunch =====");
    // print("Mensaje: $message");
    final argumento = message['data'];
    _mensajesStreamController.sink.add(argumento);
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    print("==== onResume =====");
    // print("Mensaje: $message");
    final argumento = message['data'];
    _mensajesStreamController.sink.add(argumento);
  }

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Manejar la data de la notificación
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Manejar el envio de la notificación
      final dynamic notification = message['notification'];
    }
    // Hacer otra cosa si es necesario
  }

  Future<Map<String, dynamic>> sendNotificaction(
      String aliadoid, String ordenid) async {
    // String nombreAliado;
    String token;

    // User user = await FirebaseAuth.instance.currentUser;
    // await FirebaseFirestore.instance.collection('Aliados').doc(PetshopApp.sharedPreferences.getString(PetshopApp.userUID)).get().then((DocumentSnapshot documentSnapshot) => {
    //   nombreAliado = documentSnapshot['nombre']
    // });
    await FirebaseFirestore.instance
        .collection('Aliados')
        .doc(aliadoid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      token = documentSnapshot.data()['token'];
    });

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': "Priority Pet",
            'body':
            PetshopApp.sharedPreferences.getString(PetshopApp.userNombre) +
                " ha procesado la orden " +
                ordenid +
                " exitosamente",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'to': token,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();
    return completer.future;
  }

  Future<Map<String, dynamic>> sendMessageNotificaction(
      String aliadoId, String message) async {
    String nombreAliado;
    String token;

    // User user = await FirebaseAuth.instance.currentUser;
    // await FirebaseFirestore.instance.collection('Aliados').doc(user.uid).get().then((DocumentSnapshot documentSnapshot) => {
    //   nombreAliado = documentSnapshot['nombre']
    // });
    await FirebaseFirestore.instance
        .collection('Aliados')
        .doc(aliadoId)
        .get()
        .then((DocumentSnapshot documentSnapshot) =>
    {token = documentSnapshot['token']});

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': PetshopApp.sharedPreferences.get(PetshopApp.userNombre) + " " +
                PetshopApp.sharedPreferences.get(PetshopApp.userApellido),
            'body': message
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'to': token,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();
    return completer.future;
  }

  dispose() {
    _mensajesStreamController?.close();
  }
}
