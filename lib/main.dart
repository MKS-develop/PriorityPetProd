import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pet_shop/Authentication/autenticacion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_shop/Config/config.dart';
import 'Config/config.dart';
import 'Store/PushNotificationsProvider.dart';
import 'Store/storehome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PetshopApp.auth = FirebaseAuth.instance;
  PetshopApp.sharedPreferences = await SharedPreferences.getInstance();
  PetshopApp.firestore = FirebaseFirestore.instance;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {

    final pushProvider = PushNotificationsProvider();

    pushProvider.initNotifications();
    pushProvider.mensajeStream.listen((argumento) {
      //Ir a ordenes después de recibir la notificación
      navigatorKey.currentState
          .push(MaterialPageRoute(builder: (context) => StoreHome()));
      // scaffoldKey.currentState.showSnackBar(snackbar);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          // const Locale('en', ''),
          const Locale('es', 'VE'),
        ],
        title: 'pet-Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Product Sans',
          primaryColor: Color(0xFF57419D),
        ),
        home: SplashScreen());

  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  displaySplash() {
    Timer(Duration(seconds: 3), () async {
      User user = await FirebaseAuth.instance.currentUser;

      if (user != null) {
        Route route = MaterialPageRoute(builder: (_) => StoreHome());
        Navigator.pushReplacement(context, route);
      } else {
        Route route = MaterialPageRoute(builder: (_) => AutenticacionPage());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("diseñador/SplashScreen2.png"),
          fit: BoxFit.cover,
        ),
      ),
    ));
  }
}
