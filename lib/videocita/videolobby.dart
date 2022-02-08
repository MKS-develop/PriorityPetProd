import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:jitsi_meet/feature_flag/feature_flag.dart';
// import 'package:jitsi_meet/jitsi_meet.dart';
// import 'package:jitsi_meet/jitsi_meeting_listener.dart';
// import 'package:jitsi_meet/room_name_constraint.dart';
// import 'package:jitsi_meet/room_name_constraint_type.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/especialidades.dart';
import 'package:pet_shop/Models/item.dart';
import 'package:pet_shop/Models/ordenes.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/myDrawer.dart';

// void main() => runApp(MyApp());

class VideoLobby extends StatefulWidget {
  final PetModel petModel;
  final OrderModel orderModel;
  final ItemModel itemModel;
  final int defaultChoiceIndex;
  VideoLobby(
      {this.petModel,
      this.orderModel,
      this.itemModel,
      this.defaultChoiceIndex});

  @override
  _VideoLobbyState createState() => _VideoLobbyState();
}

class _VideoLobbyState extends State<VideoLobby> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "PriorityPet001");
  final subjectText = TextEditingController(text: "Videoconsulta veterinaria");
  final nameText = TextEditingController(
    text:
        PetshopApp.sharedPreferences.getString(PetshopApp.userName) ?? 'Dueño',
  );
  final emailText = TextEditingController(
    text: PetshopApp.sharedPreferences.getString(PetshopApp.userEmail) ??
        'Correo del dueño',
  );
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;
  String aliadoAvatar;

  @override
  void initState() {
    super.initState();
    // JitsiMeet.addListener(JitsiMeetingListener(
    //     onConferenceWillJoin: _onConferenceWillJoin,
    //     onConferenceJoined: _onConferenceJoined,
    //     onConferenceTerminated: _onConferenceTerminated,
    //     onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
    //     onPictureInPictureTerminated: _onPictureInPictureTerminated,
    //     onError: _onError));
    roomText.value = TextEditingValue(text: widget.orderModel.videoId);
    // doctor.value = TextEditingValue(text: widget.orderModel.nombreComercial);
    _getAliado();
  }

  _getAliado() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("Aliados")
        .doc(widget.orderModel.aliadoId);
    documentReference.get().then((dataSnapshot) {
      setState(() {
        aliadoAvatar = (dataSnapshot["avatar"]);
        // ppCanjeados = (dataSnapshot.data()["ppCanjeados"]);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        body: Container(
          // decoration: new BoxDecoration(
          //   image: new DecorationImage(
          //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
          //     fit: BoxFit.cover,
          //
          //   ),
          // ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Color(0xFF57419D)),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        "Videoconsulta",
                        style: TextStyle(
                          color: Color(0xFF57419D),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 24.0,
                // ),
                // TextField(
                //   controller: serverText,
                //   decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: "Server URL",
                //       hintText: "Hint: Leave empty for meet.jitsi.si"),
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // TextField(
                //   controller: roomText,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: "Sala",
                //   ),
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // TextField(
                //   controller: subjectText,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: "Asunto",
                //   ),
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // TextField(
                //   controller: nameText,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: "Nombre titular",
                //   ),
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // TextField(
                //   controller: emailText,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: "Email",
                //   ),
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // CheckboxListTile(
                //   title: Text("Sólo Audio"),
                //   value: isAudioOnly,
                //   onChanged: _onAudioOnlyChanged,
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // CheckboxListTile(
                //   title: Text("Sin Audio"),
                //   value: isAudioMuted,
                //   onChanged: _onAudioMutedChanged,
                // ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // CheckboxListTile(
                //   title: Text("Sin Video"),
                //   value: isVideoMuted,
                //   onChanged: _onVideoMutedChanged,
                // ),
                // Divider(
                //   height: 48.0,
                //   thickness: 2.0,
                // ),
                Stack(
                  children: [
                    _fondoImagen(),
                    _cuerpo(),
                  ],
                ),

                SizedBox(
                  height: 40.0,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      // _joinMeeting();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Color(0xFFEB9448),
                    padding: EdgeInsets.all(5.0),
                    child: Text("Ingresar a la consulta",
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cuerpo() {
    return Column(
      children: <Widget>[
        _menu(),
        _iconos(),
        _valor(),
        _multimedia(),
        // _filaAgenda(),
      ],
    );
  }

  Widget _multimedia() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: ClipOval(
            child: Material(
              color: isAudioMuted != false
                  ? Colors.red
                  : Color(0xFF57419D), // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 36,
                    )),
                onTap: () {
                  if (isAudioMuted == true) {
                    setState(() {
                      isAudioMuted = false;
                    });
                  } else {
                    setState(() {
                      isAudioMuted = true;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: ClipOval(
            child: Material(
              color: isVideoMuted != false
                  ? Colors.red
                  : Color(0xFF57419D), // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.video_call_outlined,
                      color: Colors.white,
                      size: 36,
                    )),
                onTap: () {
                  if (isVideoMuted == true) {
                    setState(() {
                      isVideoMuted = false;
                    });
                  } else {
                    setState(() {
                      isVideoMuted = true;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 70.0, 0, 10.0),
      child: Column(
        children: [
          // Text('Los mejores productos', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),),
          // Text('Porque tu mascota se lo merece', style: TextStyle(color: Colors.white, fontSize: 16.0),)
        ],
      ),
    );
  }

  Widget _iconos() {
    return Column(
      children: [
        SizedBox(
          height: 60.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300.0,
              height: 100.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Alimento";
                  _planModalBottomSheet(context);
                  // Navigator.push(
                  //   context,
                  //
                  //   MaterialPageRoute(builder: (context) => AlimentoHome(petModel: model, tituloDetalle: tituloDetalle)),
                  // );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Color(0xFFF4F6F8),
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(widget.orderModel.nombreComercial,
                            style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFF57419D),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                      ],
                    ),
                    // SizedBox(
                    //   height: 2.0,
                    // ),
                    // Text(widget.locationModel.direccionLocalidad,
                    //     style: TextStyle(fontSize: 12.0)),
                    SizedBox(
                      height: 2.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // widget.aliadoModel.tipoAliado != 'Médico'
                        //     ? Text(
                        //   widget.serviceModel.titulo,
                        //   style: TextStyle(
                        //     color: Colors.grey,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // )
                        //     :
                        Container(
                          width: 180,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("Aliados")
                                  .doc(widget.orderModel.aliadoId)
                                  .collection("Especialidades")
                                  .snapshots(),
                              builder: (context, dataSnapshot) {
                                if (dataSnapshot.hasData) {
                                  if (dataSnapshot.data.docs.length == 0) {
                                    return Center(child: Container());
                                  }
                                }
                                if (!dataSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: dataSnapshot.data.docs.length,
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      EspecialidadesModel especialidades =
                                          EspecialidadesModel.fromJson(
                                              dataSnapshot.data.docs[index]
                                                  .data());
                                      return Row(
                                        children: [
                                          Text(
                                            especialidades.especialidad,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              }),
                        ),
                        Icon(
                          Icons.info_outline_rounded,
                          size: 30,
                          color: Color(0xFF277EB6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _fondoImagen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 170.0,
            width: 200.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: Image(
                image: NetworkImage(aliadoAvatar),
                fit: BoxFit.cover,
                errorBuilder: (context, object, stacktrace) {
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valor() {
    return Container(
      width: 350,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Hora de consulta: ${widget.itemModel.hora}',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Text(
          //       'S/',
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold),
          //     ),
          //     Text(
          //       (widget.serviceModel.precio).toString(),
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  void _planModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              color:
                  Color(0xFF737373), //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor

              child: Container(
                  width: 60.0,
                  height: MediaQuery.of(context).size.height,
                  decoration: new BoxDecoration(
                      color: Color(0xFFEB9448),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: new Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          width: 70.0,
                          height: 5.0,
                          child: Image.asset(
                            'diseñador/drawable/Rectangulo308.png',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        widget.orderModel.nombreComercial,
                        style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Aliados")
                              .doc(widget.orderModel.aliadoId)
                              .collection("Especialidades")
                              .snapshots(),
                          builder: (context, dataSnapshot) {
                            if (dataSnapshot.hasData) {
                              if (dataSnapshot.data.docs.length == 0) {
                                return Center(child: Container());
                              }
                            }
                            if (!dataSnapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                itemCount: dataSnapshot.data.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  EspecialidadesModel especialidades =
                                      EspecialidadesModel.fromJson(
                                          dataSnapshot.data.docs[index].data());

                                  return Column(
                                    children: [
                                      Text(
                                        especialidades.especialidad,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Certificación: ',
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            especialidades.certificado,
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          especialidades.hojaProfesional ==
                                                  'null'
                                              ? especialidades.hojaProfesional
                                              : '',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          }),
                      // widget.aliadoModel.tipoAliado != 'Médico'
                      //     ? Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       widget.serviceModel.titulo,
                      //       style: TextStyle(
                      //         color: Colors.grey,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],
                      // )
                      //     : Container(),
                    ],
                  )));
        });
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  // _joinMeeting() async {
  //   String serverUrl =
  //   serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;
  //
  //   try {
  //     // Enable or disable any feature flag here
  //     // If feature flag are not provided, default values will be used
  //     // Full list of feature flags (and defaults) available in the README
  //     FeatureFlag featureFlag = FeatureFlag();
  //     featureFlag.welcomePageEnabled = false;
  //     // Here is an example, disabling features for each platform
  //     if (Platform.isAndroid) {
  //       // Disable ConnectionService usage on Android to avoid issues (see README)
  //       featureFlag.callIntegrationEnabled = false;
  //     } else if (Platform.isIOS) {
  //       // Disable PIP on iOS as it looks weird
  //       featureFlag.pipEnabled = true;
  //
  //     }
  //
  //     //uncomment to modify video resolution
  //     //featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;
  //
  //     // Define meetings options here
  //     var options = JitsiMeetingOptions()
  //       ..room = roomText.text
  //       ..serverURL = serverUrl
  //       ..subject = subjectText.text
  //       ..userDisplayName = nameText.text
  //       ..userEmail = emailText.text
  //       ..audioOnly = isAudioOnly
  //       ..audioMuted = isAudioMuted
  //       ..videoMuted = isVideoMuted
  //       ..featureFlag = featureFlag;
  //
  //     debugPrint("JitsiMeetingOptions: $options");
  //     await JitsiMeet.joinMeeting(
  //       options,
  //       listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
  //         debugPrint("${options.room} will join with message: $message");
  //       }, onConferenceJoined: ({message}) {
  //         debugPrint("${options.room} joined with message: $message");
  //       }, onConferenceTerminated: ({message}) {
  //         debugPrint("${options.room} terminated with message: $message");
  //       }, onPictureInPictureWillEnter: ({message}) {
  //         debugPrint("${options.room} entered PIP mode with message: $message");
  //       }, onPictureInPictureTerminated: ({message}) {
  //         debugPrint("${options.room} exited PIP mode with message: $message");
  //       }),
  //       // by default, plugin default constraints are used
  //       //roomNameConstraints: new Map(), // to disable all constraints
  //       //roomNameConstraints: customContraints, // to use your own constraint(s)
  //     );
  //   } catch (error) {
  //     debugPrint("error: $error");
  //   }
  // }

  // static final Map<RoomNameConstraintType, RoomNameConstraint>
  // customContraints = {
  //   RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
  //     return value.trim().length <= 50;
  //   }, "Maximum room name length should be 30."),
  //   RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
  //     return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
  //         .hasMatch(value) ==
  //         false;
  //   }, "Currencies characters aren't allowed in room names."),
  // };

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  void _onPictureInPictureWillEnter({message}) {
    debugPrint(
        "_onPictureInPictureWillEnter broadcasted with message: $message");
  }

  void _onPictureInPictureTerminated({message}) {
    debugPrint(
        "_onPictureInPictureTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
