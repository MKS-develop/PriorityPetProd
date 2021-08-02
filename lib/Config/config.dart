import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PetshopApp {
  static const String appName = 'Priority Pet';

  static SharedPreferences sharedPreferences;
  static User user;
  static FirebaseAuth auth;
  static FirebaseFirestore firestore;

  static String collectionUser = "users";
  static String collectionOrders = "orders";
  static String userCartList = 'userCart';
  static String subCollectionAddress = 'userAddress';

  static final String userName = 'user';
  static final String userEmail = 'email';
  static final String userPhotoUrl = 'photoUrl';
  static final String userUID = 'uid';
  static final String userAvatarUrl = 'url';
  static final String userFechaNac = 'fechaNacimiento';
  static final String userNombre = 'nombre';
  static final String userApellido = 'apellido';
  static final String userGenero = 'genero';
  static final String userPais = 'pais';
  static final String userDireccion = 'direccion';
  static final String userTelefono = 'telefono';
  static final String userDocId = 'docid';
  static final String userToken = 'token';
  static final String userBienvenida = 'bienvenida';
  static final String userCulqi = 'id_culqi';
  static final String simboloMoneda = 'simbolo';
  static final String Moneda = 'moneda';
  static final String codigoTexto = 'codigoTexto';
  static final String tipoDocumento = 'tipoDocumento';
  static final String geolocation = 'geolocation';
  static final String geoAddress = 'geoAddress';

  static final String addressID = 'addressID';
  static final String totalAmount = 'totalAmount';
  static final String productID = 'productIDs';
  static final String paymentDetails = 'paymentDetails';
  static final String orderTime = 'orderTime';
  static final String isSuccess = 'isSuccess';
}
