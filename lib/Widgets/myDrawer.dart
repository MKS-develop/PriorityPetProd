import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Authentication/autenticacion.dart';
import 'package:pet_shop/Beneficios/planeshome.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/DialogBox/choosepetDialog.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Ordenes/newordeneshome.dart';
import 'package:pet_shop/Payment/payment.dart';
import 'package:pet_shop/Petpoints/petpointshome.dart';
import 'package:pet_shop/Reclamos/reclamos.dart';
import 'package:pet_shop/Referidos/referidos.dart';
import 'package:pet_shop/Store/notificaciones.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Store/signuphelpscreen.dart';
import 'package:pet_shop/mascotas/mascotashome.dart';
import 'package:pet_shop/usuario/usuarioinfo.dart';

import 'ktitle.dart';

class MyDrawer extends StatelessWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  final String quality;

  MyDrawer({this.petModel, this.defaultChoiceIndex, this.quality });



  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Container(
        // color: Color(0xFF57419D),
        child: ListView(
          children: [
            Container(

              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF57419D),),
                accountName: Text(
                    PetshopApp.sharedPreferences.getString(PetshopApp.userNombre) ?? 'Nombre del dueño',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17
                    )
                ),
                accountEmail: Text(
                    PetshopApp.sharedPreferences.getString(PetshopApp.userEmail) ?? 'Email del dueño'
                ),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UsuarioInfo(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).platform == TargetPlatform.iOS ? Color(0xFF57419D) : Colors.white,
                    backgroundImage: Image.network(
                        PetshopApp.sharedPreferences.getString(PetshopApp.userAvatarUrl),
                        errorBuilder: (context, object, stacktrace) {
                          return Container();
                        },
                    ).image,
                  ),
                ),
              ),
            ),


            ListTile(
              leading: Icon(
                  Icons.face,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Mi cuenta", style: TextStyle(color: Color(0xFF57419D),
                  // .withOpacity(0.5),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UsuarioInfo(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ),
            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5),
            // ),
            ListTile(
              leading: Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Mis mascotas", style: TextStyle(color: Color(0xFF57419D),

                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MascotasHome(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex)),
                );
              },
            ),
            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5),
            // ),
            ListTile(
              leading: Icon(
                  Icons.list_alt_rounded,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Mis órdenes", style: TextStyle(color: Color(0xFF57419D),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewOrdenesHome(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ),
            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5),
            // ),
            ListTile(
              leading: Container(
                height: 25,
                child: Image.asset(
                  'diseñador/drawable/petpoint.png',
                  color: Color(0xFF57419D),
                  fit: BoxFit.cover,

                ),
              ),
              // Icon(
              //     Icons.monetization_on,
              //     color: Color(0xFF57419D).w // Icon(
              //             //     Icons.monetization_on,
              //             //     color: Color(0xFF57419D).withOpacity(0.5),
              //             //     size: 26
              //             // ),ithOpacity(0.5),
              //     size: 26
              // ),
              title: Text("Mis Pet Points", style: TextStyle(color: Color(0xFF57419D),
                  // .withOpacity(0.5),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PetPointsHome(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ),

            ListTile(
              leading:
              // Container(
              //   height: 25,
              //   child: Image.asset(
              //     'diseñador/drawable/petpoint.png',
              //     color: Color(0xFF57419D),
              //     fit: BoxFit.cover,
              //
              //   ),
              // ),
              Icon(
                  Icons.monetization_on,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Beneficios", style: TextStyle(color: Color(0xFF57419D),
                  // .withOpacity(0.5),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
    if (petModel == null) {
                {
                  showDialog(
                      builder: (context) =>
                          new ChoosePetAlertDialog(
                            message:
                                "Por favor seleccione una mascota para poder disfrutar de este y otros servicios.",
                          ),
                      context: context);
                }
              }
              if (PetshopApp.sharedPreferences
                          .getString(PetshopApp.userPais) ==
                      "Perú" &&
                  petModel != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlanesHome(
                            petModel: petModel,
                            defaultChoiceIndex:
                                defaultChoiceIndex,
                          )),
                );
              }
              if (PetshopApp.sharedPreferences
                      .getString(PetshopApp.userPais) !=
                  "Perú") {
                showDialog(
                    builder: (context) =>
                        new ChoosePetAlertDialog(
                          message:
                              "No estan disponibles planes para tu pais",
                        ),
                    context: context);
              }
              },
            ),
            PetshopApp.sharedPreferences.getString(PetshopApp.userPais) =='Perú' ?
            ListTile(
              leading: Icon(
                  Icons.monetization_on,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Métodos de pago", style: TextStyle(color: Color(0xFF57419D),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentPage(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ): Container(),
            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5)
            // ),
            ListTile(
              leading: Icon(
                  Icons.notifications,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Notificaciones", style: TextStyle(color: Color(0xFF57419D),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificacionesPage(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ),

            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5),
            // ),
            ListTile(
              leading: Icon(
                  Icons.send_rounded,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Invita a un amigo", style: TextStyle(color: Color(0xFF57419D),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReferidosPage(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ),

            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5),
            // ),
            ListTile(
              leading: Icon(
                  Icons.help,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Ayuda", style: TextStyle(color: Color(0xFF57419D),

                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpHelpScreen()),
                );
              },
            ),







            // Divider(
            //           indent: 20,
            //           endIndent: 40,
            //           color: Color(0xFF57419D).withOpacity(0.5),
            //         ),
            ListTile(
              leading: Icon(
                  Icons.quick_contacts_mail_rounded,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Reclamos", style: TextStyle(color: Color(0xFF57419D),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReclamosPage(petModel: petModel, defaultChoiceIndex: defaultChoiceIndex,)),
                );
              },
            ),
            // Divider(
            //   indent: 20,
            //   endIndent: 40,
            //   color: Color(0xFF57419D).withOpacity(0.5),
            // ),
            SizedBox(height: 30.0,),
            ListTile(
              leading: Icon(
                  Icons.logout,
                  color: Color(0xFF57419D).withOpacity(0.5),
                  size: 26
              ),
              title: Text("Cerrar sesión", style: TextStyle(color: Color(0xFF57419D),
                  fontWeight: FontWeight.w300,
                  fontSize: 17),),
              onTap: (){
                PetshopApp.auth.signOut().then((c){
                  Route route = MaterialPageRoute(builder: (c) => AutenticacionPage());
                  Navigator.pushReplacement(context, route);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(quality!= null ? 'V1.1.1 $quality' : 'V1.1.1', style: TextStyle(color: textColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 13),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
