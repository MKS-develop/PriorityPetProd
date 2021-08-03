import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Store/storehome.dart';
import 'package:pet_shop/Widgets/ktitle.dart';

class SignUpHelpScreen extends StatefulWidget {
  @override
  _SignUpHelpScreenState createState() => _SignUpHelpScreenState();
}

class _SignUpHelpScreenState extends State<SignUpHelpScreen> {
  final int _numPages = 5;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : primaryLightColor.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      var bienv = FirebaseFirestore.instance
                          .collection("Dueños")
                          .doc(PetshopApp.sharedPreferences
                              .getString(PetshopApp.userUID));
                      bienv.update({
                        'bienvenida': false,
                      });
                    },
                    child: Text(
                      'Omitir',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 560.0,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Bienvenido a PriorityPet',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              PetshopApp.sharedPreferences
                                  .getString(PetshopApp.userName),
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Sigue estos pasos para la configuración básica de inicio.',
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(35.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/ayudaingresa.png',
                                ),
                                height: 280.0,
                                width: 280.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Registra tus\nmascotas',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Ingresando en el simbolo  \u{2795}  de la vista principal, podrás agregarlas una a una.',
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/ayudaregistro.png',
                                ),
                                height: 300.0,
                                width: 300.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              "Ingresa en 'Beneficios'",
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "Para explorar los Planes que tenemos para ti.",
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/ayudanavega.png',
                                ),
                                height: 300.0,
                                width: 300.0,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Navega en la app',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "Comienza a navegar por las opciones de servicio enfocadas en el cuidado y la salud de tus mascotas.",
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Con estos 3 pasos, podrás disfrutar de los servicios de la comunidad Priority Pet.',
                              style: kTitleStyle,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Gracias por ser parte de la comunidad Priority Pet.',
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPages - 1
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Continuar',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 100.0,
              width: double.infinity,
              color: primaryDarkColor,
              child: GestureDetector(
                onTap: () {
                  var bienv = FirebaseFirestore.instance
                      .collection("Dueños")
                      .doc(PetshopApp.sharedPreferences
                          .getString(PetshopApp.userUID));
                  bienv.update({
                    'bienvenida': false,
                  });
                  Route route = MaterialPageRoute(builder: (_) => StoreHome());
                  Navigator.pushReplacement(context, route);
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StoreHome()));
                  // });
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'Comenzar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}
