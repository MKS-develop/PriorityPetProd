import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_shop/DialogBox/errorDialog.dart';
import 'package:pet_shop/Models/pet.dart';
import 'package:pet_shop/Widgets/customTextField.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:intl/date_symbol_data_local.dart';

double width;

class RegistroMascota extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;

  RegistroMascota({this.petModel, this.defaultChoiceIndex});
  @override
  _RegistroMascotaState createState() => _RegistroMascotaState();
}

class _RegistroMascotaState extends State<RegistroMascota>
    with AutomaticKeepAliveClientMixin<RegistroMascota> {
  final TextEditingController _namepetTextEditingController =
      TextEditingController();
  final TextEditingController _datepetTextEditingController =
      TextEditingController();
  final TextEditingController _date2petTextEditingController =
      TextEditingController();
  final TextEditingController _aboutpetTextEditingController =
      TextEditingController();
  final TextEditingController _sexTextEditingController =
      TextEditingController();
  final TextEditingController _razaTextEditingController =
      TextEditingController();
  final GlobalKey<FormState> _petformKey = GlobalKey<FormState>();
  String _categoria;
  String _raza;
  String _sexo;
  DateTime selectedDate = DateTime.now();

  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;

  String petImageUrl = "";
  String downloadUrl;
  bool get wantKeepAlive => true;
  PickedFile file;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // //initializeDateFormatting("es_VE", null).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return new Scaffold(
      appBar: PreferredSize(
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
                Route route = MaterialPageRoute(builder: (c) => StoreHome());
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
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          PetshopApp.sharedPreferences
                              .getString(PetshopApp.userAvatarUrl),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(
        petModel: widget.petModel,
        defaultChoiceIndex: widget.defaultChoiceIndex,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Form(
                key: _petformKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    color: Color(0xFF57419D)),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            Text(
                              "Mascota",
                              style: TextStyle(
                                color: Color(0xFF57419D),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            uploading ? linearProgress() : Text(""),
                            InkWell(
                              onTap: _selectAndPickImage,
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: Color(0xFF86A3A3),
                                child: file != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Image.file(
                                          File(file.path),
                                          width: width,
                                          height: 150.0,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        width: 70,
                                        height: 70,
                                        child: Icon(
                                          Icons.add_photo_alternate,
                                          color: Color(0xFF86A3A3),
                                        ),
                                      ),
                              ),
                              // CircleAvatar(
                              //   backgroundColor: Color(0xFF7F9D9D),
                              //   radius: _screenWidth * 0.09,
                              //   child: CircleAvatar(
                              //     radius: _screenWidth * 0.085,
                              //     backgroundColor: Colors.white,
                              //     backgroundImage:
                              //         file == null ? null : Image.file(file),
                              //     child: file == null
                              //         ? Icon(Icons.add_photo_alternate,
                              //             size: _screenWidth * 0.08,
                              //             color: Color(0xFF7F9D9D))
                              //         : null,
                              //   ),
                              // ),
                            ),
                            SizedBox(height: 10.0),
                            Text("Foto de tu mascota",
                                style: TextStyle(
                                  color: Color(0xFF7F9D9D),
                                  fontSize: 16.0,
                                )),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Mi nombre',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF7F9D9D)),
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: _namepetTextEditingController,
                      hintText: ("Escribe el nombre de tu mascota"),
                      isObsecure: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Fecha de nacimiento',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF7F9D9D)),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _planModalBottomSheet(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _date2petTextEditingController,
                          keyboard: TextInputType.datetime,
                          hintText: "¿Cuando nació tu mascota?",
                          isObsecure: false,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            '¿Cuál es mi especie?',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF7F9D9D)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: _screenWidth * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("Especies")
                                        .orderBy('createdOn', descending: false)
                                        .snapshots(),
                                    builder: (context, dataSnapshot) {
                                      if (!dataSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        List<DropdownMenuItem> list = [];
                                        for (int i = 0;
                                            i < dataSnapshot.data.docs.length;
                                            i++) {
                                          DocumentSnapshot snap =
                                              dataSnapshot.data.docs[i];
                                          list.add(
                                            DropdownMenuItem(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 0, 0, 0),
                                                child: Text(
                                                  snap.id,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              value: "${snap.id}",
                                            ),
                                          );
                                        }
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFF7f9d9D),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          padding: EdgeInsets.all(0.0),
                                          margin: EdgeInsets.all(5.0),
                                          child: DropdownButtonHideUnderline(
                                            child: Stack(
                                              children: <Widget>[
                                                DropdownButton(
                                                    hint: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Text(
                                                          '¿Qué tipo de mascota es?',
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              color: Color(
                                                                  0xFF7f9d9D))),
                                                    ),
                                                    items: list,
                                                    isExpanded: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _categoria = value;
                                                        print(_categoria);
                                                      });
                                                    },
                                                    value: _categoria),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Esta es mi raza',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF7F9D9D)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: _screenWidth * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("Especies")
                                        .doc(_categoria)
                                        .collection("Razas")
                                        .orderBy('createdOn', descending: false)
                                        .snapshots(),
                                    builder: (context, dataSnapshot) {
                                      if (!dataSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        List<String> list = [];
                                        for (int i = 0;
                                            i <
                                                dataSnapshot
                                                    .data.documents.length;
                                            i++) {
                                          DocumentSnapshot razas =
                                              dataSnapshot.data.documents[i];
                                          list.add(
                                            razas.documentID,
                                          );
                                        }
                                        return Container(
                                          height: 55,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFF7f9d9D),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          padding:
                                              EdgeInsets.fromLTRB(15, 0, 0, 0),
                                          margin: EdgeInsets.all(5.0),

                                          child: DropdownSearch<String>(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              hintStyle: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Color(0xFF7f9d9D)),
                                              disabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabled: false,
                                              border: InputBorder.none,
                                            ),
                                            mode: Mode.BOTTOM_SHEET,
                                            maxHeight: 300,
                                            // searchBoxController:
                                            //     _razaTextEditingController,
                                            // popupBackgroundColor: Colors.amber,
                                            // searchBoxDecoration: InputDecoration(
                                            //   fillColor: Colors.blue,
                                            // ),
                                            showSearchBox: true,
                                            showSelectedItem: true,
                                            items: list,
                                            // label: "Menu mode",
                                            hint:
                                                "¿Cuál es la raza de tu mascota?",

                                            popupItemDisabled: (String s) =>
                                                s.startsWith('I'),
                                            onChanged: (value) {
                                              setState(() {
                                                _razaTextEditingController
                                                    .text = value;
                                              });
                                            },
                                            // selectedItem: _razaTextEditingController.text,
                                          ),

                                          // child: DropdownButtonHideUnderline(
                                          //   child: Stack(
                                          //     children: <Widget>[
                                          //       DropdownButton(
                                          //           hint: Padding(
                                          //             padding: const EdgeInsets
                                          //                 .fromLTRB(
                                          //                 15, 0, 0, 0),
                                          //             child: Text(
                                          //                 '¿Cuál es la raza de tu mascota?',
                                          //                 style: TextStyle(
                                          //                     fontSize: 15.0,
                                          //                     color: Color(
                                          //                         0xFF7f9d9D))),
                                          //           ),
                                          //           items: list,
                                          //           isExpanded: true,
                                          //           onChanged: (value) {
                                          //             setState(() {
                                          //               _raza = value;
                                          //             });
                                          //           },
                                          //           value: _raza),
                                          //     ],
                                          //   ),
                                          // ),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Container(
                    //         width: _screenWidth * 0.9,
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             StreamBuilder<QuerySnapshot>(
                    //                 stream: FirebaseFirestore.instance
                    //                     .collection("Especies")
                    //                     .doc(_categoria)
                    //                     .collection("Razas")
                    //                     .orderBy('createdOn', descending: false)
                    //                     .snapshots(),
                    //                 builder: (context, dataSnapshot) {
                    //                   if (!dataSnapshot.hasData) {
                    //                     return Center(
                    //                       child: CircularProgressIndicator(),
                    //                     );
                    //                   } else {
                    //                     List<DropdownMenuItem> list = [];
                    //                     for (int i = 0;
                    //                         i <
                    //                             dataSnapshot
                    //                                 .data.documents.length;
                    //                         i++) {
                    //                       DocumentSnapshot razas =
                    //                           dataSnapshot.data.documents[i];
                    //                       list.add(
                    //                         DropdownMenuItem(
                    //                           child: Padding(
                    //                             padding:
                    //                                 const EdgeInsets.fromLTRB(
                    //                                     15, 0, 0, 0),
                    //                             child: Text(
                    //                               razas.documentID,
                    //                               style: TextStyle(
                    //                                 color: Colors.black,
                    //                               ),
                    //                             ),
                    //                           ),
                    //                           value: "${razas.documentID}",
                    //                         ),
                    //                       );
                    //                     }
                    //                     return Container(
                    //                       decoration: BoxDecoration(
                    //                         color: Colors.white,
                    //                         border: Border.all(
                    //                           color: Color(0xFF7f9d9D),
                    //                           width: 1.0,
                    //                         ),
                    //                         borderRadius: BorderRadius.all(
                    //                             Radius.circular(10.0)),
                    //                       ),
                    //                       padding: EdgeInsets.all(0.0),
                    //                       margin: EdgeInsets.all(5.0),
                    //                       child: DropdownButtonHideUnderline(
                    //                         child: Stack(
                    //                           children: <Widget>[
                    //                             DropdownButton(
                    //                                 hint: Padding(
                    //                                   padding: const EdgeInsets
                    //                                           .fromLTRB(
                    //                                       15, 0, 0, 0),
                    //                                   child: Text(
                    //                                       '¿Cuál es la raza de tu mascota?',
                    //                                       style: TextStyle(
                    //                                           fontSize: 15.0,
                    //                                           color: Color(
                    //                                               0xFF7f9d9D))),
                    //                                 ),
                    //                                 items: list,
                    //                                 isExpanded: true,
                    //                                 onChanged: (value) {
                    //                                   setState(() {
                    //                                     _raza = value;
                    //                                   });
                    //                                 },
                    //                                 value: _raza),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     );
                    //                   }
                    //                 }),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Mi sexo',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF7F9D9D)),
                          ),
                        ),
                      ],
                    ),

                    // Container(
                    //   height: 52,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     border: Border.all(
                    //       color: Color(0xFF7f9d9D),
                    //       width: 1.0,
                    //     ),
                    //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //   ),
                    //   padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    //   margin: EdgeInsets.all(5.0),
                    //   width: _screenWidth * 0.9,
                    //
                    //   child: DropdownSearch<String>(
                    //     dropdownSearchDecoration: InputDecoration(
                    //
                    //       disabledBorder: InputBorder.none,
                    //
                    //       focusedBorder: InputBorder.none,
                    //       enabled: false,
                    //       border: InputBorder.none,
                    //     ),
                    //     mode: Mode.MENU,
                    //     searchBoxController: _sexTextEditingController,
                    //     // popupBackgroundColor: Colors.amber,
                    //     // searchBoxDecoration: InputDecoration(
                    //     //   fillColor: Colors.blue,
                    //     // ),
                    //     showSearchBox: true,
                    //     showSelectedItem: true,
                    //     items: ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
                    //     // label: "Menu mode",
                    //     hint: "country in menu mode",
                    //     popupItemDisabled: (String s) => s.startsWith('I'),
                    //     onChanged: print,
                    //     // selectedItem: "Brazil"
                    //   ),
                    // ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: _screenWidth * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("SexoMascota")
                                        .snapshots(),
                                    builder: (context, dataSnapshot) {
                                      if (!dataSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        List<DropdownMenuItem> list = [];
                                        for (int i = 0;
                                            i < dataSnapshot.data.docs.length;
                                            i++) {
                                          DocumentSnapshot sex =
                                              dataSnapshot.data.docs[i];
                                          list.add(
                                            DropdownMenuItem(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 0, 0, 0),
                                                child: Text(
                                                  sex.id,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              value: "${sex.id}",
                                            ),
                                          );
                                        }
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFF7f9d9D),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          padding: EdgeInsets.all(0.0),
                                          margin: EdgeInsets.all(5.0),
                                          child: DropdownButtonHideUnderline(
                                            child: Stack(
                                              children: <Widget>[
                                                DropdownButton(
                                                    hint: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          15, 0, 0, 0),
                                                      child: Text(
                                                          'Indica su sexo',
                                                          style: TextStyle(
                                                              fontSize: 15.0,
                                                              color: Color(
                                                                  0xFF7f9d9D))),
                                                    ),
                                                    items: list,
                                                    isExpanded: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _sexo = value;
                                                      });
                                                    },
                                                    value: _sexo),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Acerca de mi',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF7F9D9D)),
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: _aboutpetTextEditingController,
                      hintText: "Describe cualidades de tu mascota",
                      isObsecure: false,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: 360,
                child: RaisedButton(
                  onPressed: () {
                    _namepetTextEditingController.text.isNotEmpty &&
                            _datepetTextEditingController.text.isNotEmpty &&
                            _aboutpetTextEditingController.text.isNotEmpty &&
                            _categoria.isNotEmpty &&
                            // _raza.isNotEmpty &&
                            _sexo.isNotEmpty &&
                            _razaTextEditingController.text.isNotEmpty &&
                            file != null
                        ? uploadImageAndSavePetInfo()
                        : showDialog(
                            context: context,
                            builder: (c) {
                              return ErrorAlertDialog(
                                message:
                                    "Por favor ingrese todos los datos de su mascota...",
                              );
                            });
                  },

                  // uploading ? null : ()=> uploadImageAndSavePetInfo(),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Color(0xFF57419D),
                  padding: EdgeInsets.all(15.0),
                  child: Text("Agrega tu mascota",
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.white,
                          fontSize: 22.0)),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    ImagePicker imagePicker = ImagePicker();
    final imageFile = await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 10);
    setState(() {
      file = imageFile;
    });
  }

  uploadImageAndSavePetInfo() async {
    setState(() {
      uploading = true;
    });

    String imageDownloadUrl = await uploadPetImage(File(file.path));

    savePetInfo(imageDownloadUrl);
  }

  Future<String> uploadPetImage(mFileImage) async {
    if (mFileImage == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: "Por favor seleccione una imagen...",
            );
          });
    } else {
      final Reference reference =
          FirebaseStorage.instance.ref().child("Mascotas");
      final UploadTask uploadTask =
          reference.child("pet_$productId.jpg").putFile(mFileImage);

      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      downloadUrl = imageUrl.toString();
      return downloadUrl;
    }
  }

  savePetInfo(String downloadUrl) {
    final databaseReference = FirebaseFirestore.instance;
    databaseReference.collection('Mascotas').doc(productId).set({
      "nombre": _namepetTextEditingController.text.trim(),
      "petthumbnailUrl": downloadUrl,
      "fechanac": DateTime.parse(_datepetTextEditingController.text),
      "especie": _categoria,
      "raza": _razaTextEditingController.text.trim(),
      "sexo": _sexo,
      "acerca": _aboutpetTextEditingController.text.trim(),
      "mid": productId,
      "uid": PetshopApp.sharedPreferences.getString(PetshopApp.userUID),
    });

    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().millisecondsSinceEpoch.toString();
      _namepetTextEditingController.clear();

      _datepetTextEditingController.clear();

      _aboutpetTextEditingController.clear();

      Route route = MaterialPageRoute(
          builder: (c) => StoreHome(
              petModel: widget.petModel,
              defaultChoiceIndex: widget.defaultChoiceIndex));
      Navigator.pushReplacement(context, route);
      Message(context, 'Se ha creado el registro de su mascota existosamente.');
    });
  }

  Future<void> Message(BuildContext context, String error) async {
    // Navigator.of(context, rootNavigator: true).pop();
    return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 400,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 55.0),
                    SizedBox(height: 20.0),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      // locale : const Locale("fr","FR"),
      initialDate: selectedDate,
      firstDate: DateTime(1980, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF57419D),
            accentColor: const Color(0xFF57419D),
            colorScheme: ColorScheme.light(primary: const Color(0xFF57419D)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String timeString = (picked).toString();
        var formatter = DateFormat.yMd('es_VE');
        String newtime = formatter.format(picked).toString();
        _date2petTextEditingController.value = TextEditingValue(text: newtime);
        _datepetTextEditingController.value =
            TextEditingValue(text: timeString.split(" ")[0]);
      });
  }

  void _planModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(context).size.height * .40,

            color: Color(0xFF737373), //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor

            child: Container(
                width: 60.0,
                decoration: new BoxDecoration(
                    color: Colors.white,
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
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedDate,
                        // maximumDate: DateTime.now(),
                        onDateTimeChanged: (datetime) {
                          setState(() {
                            selectedDate = datetime;

                            String timeString = (datetime).toString();

                            var formatter = DateFormat.yMd('es_VE');

                            String newtime =
                                formatter.format(datetime).toString();

                            _date2petTextEditingController.value =
                                TextEditingValue(text: newtime);

                            _datepetTextEditingController.value =
                                TextEditingValue(
                                    text: timeString.split(" ")[0]);
                          });
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: RaisedButton(
                    //     onPressed: () {
                    //       Navigator.of(context, rootNavigator: true).pop();
                    //     },
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(5)),
                    //     color: Color(0xFFEB9448),
                    //     padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Text("Seleccionar fecha",
                    //             style: TextStyle(
                    //                 fontFamily: 'Product Sans',
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 18.0)),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                )),
          );
        });
  }
}
