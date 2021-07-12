// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:google_map_location_picker/generated/l10n.dart'
// as location_picker;
// import 'package:google_map_location_picker/generated/l10n.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:pet_shop/usuario/usuarioinfo.dart';
//
// import '../Store/storehome.dart';
// import 'myDrawer.dart';
// import 'navbar.dart';
//
//
//
// class Location extends StatefulWidget {
//   @override
//   _LocationState createState() => _LocationState();
// }
//
// class _LocationState extends State<Location> {
//   LocationResult _pickedLocation;
//
//   String get apiKey => "AIzaSyDmb3pc-t9K9aC_mKnZBfIPQ7Il4OClCN0";
//
//   @override
//   Widget build(BuildContext context) {
//
//     return MaterialApp(
// //      theme: ThemeData.dark(),
//       debugShowCheckedModeBanner:false,
//       title: 'location picker',
//       localizationsDelegates: const [
//         location_picker.S.delegate,
//         S.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const <Locale>[
//         Locale('en'),
//         Locale('es'),
//
//       ],
//       home: Scaffold(
//
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: Colors.black),
//           backgroundColor: Colors.transparent, //No more green
//           elevation: 0.0,
//           title:     GestureDetector(
//             onTap: (){
//               print(DateTime.now());
//               Route route = MaterialPageRoute(builder: (c) => StoreHome());
//               Navigator.pushReplacement(context, route);
//             },
//             child: Image.asset(
//               'diseñador/logo.png',
//               fit: BoxFit.contain,
//               height: 40,
//             ),
//           ),
//           centerTitle: true,
//
//         ),
//         bottomNavigationBar: CustomBottomNavigationBar(),
//         drawer: MyDrawer(),
//         body: Builder(builder: (context) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     IconButton(icon: Icon(Icons.arrow_back_ios, color: Color(0xFF57419D)), onPressed: (){
//                       Route route = MaterialPageRoute(builder: (c) => UsuarioInfo());
//                       Navigator.pushReplacement(context, route);
//                     }
//                     ),
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
//                       child: Text("Ubicación", style: TextStyle(color: Color(0xFF57419D), fontSize: 20, fontWeight: FontWeight.bold,),),),
//                   ],
//                 ),
//                 RaisedButton(
//                   onPressed: () async {
//                     LocationResult result = await showLocationPicker(context, apiKey,
//                       initialCenter: LatLng(10.4806, -66.9036),
//                      automaticallyAnimateToCurrentLocation: true,
//                     // mapStylePath: 'assets/mapStyle.json',
//                       myLocationButtonEnabled: true,
//                        requiredGPS: true,
//                       layersButtonEnabled: true,
//                       language: 'es',
//                       // countries: ['AE', 'NG']
//
// //                      resultCardAlignment: Alignment.bottomCenter,
//                       desiredAccuracy: LocationAccuracy.best,
//                     );
//                     print("result = $result");
//                     setState(() => _pickedLocation = result);
//                   },
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   color: Color(0xFF57419D),
//                   padding: EdgeInsets.all(15.0),
//                   child:
//                   Text("Selecciona tu locación", style: TextStyle(
//                       fontFamily: 'Product Sans',
//                       color: Colors.white,
//                       fontSize: 18.0)),
//                 ),
//                 Text(_pickedLocation.toString()),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }