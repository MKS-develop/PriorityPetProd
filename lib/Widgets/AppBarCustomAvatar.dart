import 'package:flutter/material.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Store/storehome.dart';

import 'ktitle.dart';

// ignore: non_constant_identifier_names
Widget AppBarCustomAvatar(context, petmodel, defaultChoiceIndex) {
  return PreferredSize(
    preferredSize: Size.fromHeight(90.0),
    child: Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        top: 20,
        right: 16.0,
      ),
      child: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent, //No more green
        elevation: 0.0,
        //Shadow gone

        title: GestureDetector(
          onTap: () {
            Route route = MaterialPageRoute(builder: (c) => StoreHome(petModel: petmodel, defaultChoiceIndex: defaultChoiceIndex,));
            Navigator.pushReplacement(context, route);
          },
          child: Image.asset(
            'diseñador/logo.png',
            fit: BoxFit.contain,
            height: 40,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Stack(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.white,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: petmodel == null
                        ? Image.network(PetshopApp.sharedPreferences
                        .getString(PetshopApp.userAvatarUrl),
                        errorBuilder: (context, object, stacktrace) {
                          return Container();
                        },).image
                        : Image.network(
                          petmodel.petthumbnailUrl,
                          errorBuilder: (context, object, stacktrace) {
                            return Container();
                          },
                        ).image,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
