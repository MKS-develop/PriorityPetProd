import 'package:pet_shop/Widgets/loadingWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChoosePetAlertDialog extends StatelessWidget {
  final String message;
  const ChoosePetAlertDialog({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      key: key,
      content: Container(
          // height: 170,
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('diseñador/drawable/Grupo80.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              message,
              style: TextStyle(color: Color(0xFF57419D), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )),
    );
  }
}
