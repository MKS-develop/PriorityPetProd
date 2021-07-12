import 'package:flutter/material.dart';


circularProgress() {
  return Container(
    width: 50.0,
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.deepPurple),),
  );
}

linearProgress() {
  return Container(
    width: 50.0,
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.deepPurple),),
  );
}
