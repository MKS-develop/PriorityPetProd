import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_shop/Config/config.dart';
import 'package:pet_shop/Models/alidados.dart';

import 'package:pet_shop/Models/pet.dart';
import 'package:flutter/material.dart';
import 'package:pet_shop/Models/prod.dart';
import 'package:pet_shop/Widgets/AppBarCustomAvatar.dart';
import 'package:pet_shop/Widgets/navbar.dart';
import '../Widgets/myDrawer.dart';

import 'alimentodetalle.dart';
import 'alimentohome.dart';

double width;

class ProductosHome extends StatefulWidget {
  final PetModel petModel;
  final int defaultChoiceIndex;
  ProductosHome({this.petModel, this.defaultChoiceIndex});

  @override
  _ProductosHomeState createState() => _ProductosHomeState();
}

class _ProductosHomeState extends State<ProductosHome> {
  PetModel model;
  TextEditingController _searchTextEditingController =
      new TextEditingController();
  List _allResults = [];
  List _resultsList = [];

  @override
  void initState() {
    super.initState();

    changePet(widget.petModel);
    _searchTextEditingController.addListener(_onSearchChanged);
    // getAllSnapshots();
    MastersList();
    print('la busqueda es: $_searchTextEditingController');
  }

  ScrollController controller = ScrollController();
  String userImageUrl = "";

  final db = FirebaseFirestore.instance;
  @override
  void dispose() {
    _searchTextEditingController.removeListener(_onSearchChanged);
    _searchTextEditingController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // resultsLoaded = getCategoriesSnapshots();
  }

  MastersList() {
    FirebaseFirestore.instance
        .collection("Productos")
        .where("pais",
            isEqualTo:
                PetshopApp.sharedPreferences.getString(PetshopApp.userPais))
        .snapshots()
        .listen(createListofServices);
  }

  createListofServices(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var Doc in docs) {
      setState(() {
        _allResults.add(ProductoModel.fromFireStore(Doc));
        print(_allResults);
      });
    }
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];
    if (_searchTextEditingController.text != "") {
      for (var tituloSnapshot in _allResults) {
        var titulo = tituloSnapshot.titulo.toLowerCase();
        if (titulo.contains(_searchTextEditingController.text.toLowerCase())) {
          showResults.add(tituloSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  _onSearchChanged() {
    searchResultsList();
    print(_searchTextEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBarCustomAvatar(
            context, widget.petModel, widget.defaultChoiceIndex),
        drawer: MyDrawer(
          petModel: widget.petModel,
          defaultChoiceIndex: widget.defaultChoiceIndex,
        ),
        bottomNavigationBar:
            CustomBottomNavigationBar(petModel: widget.petModel),
        body: _fondo(),
      ),
    );
  }

  Widget _fondo() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color(0xFFf4f6f8),
      // decoration: new BoxDecoration(
      //   image: new DecorationImage(
      //     colorFilter: new ColorFilter.mode(
      //         Colors.white.withOpacity(0.3), BlendMode.dstATop),
      //     image: new AssetImage("diseñador/drawable/fondohuesitos.png"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            _fondoImagen(),
            _cuerpo(),
          ],
        ),
      ),
    );
  }

  Widget _titulo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF57419D)),
            onPressed: () {
              Navigator.pop(context);
            }),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Text(
            "Productos",
            style: TextStyle(
              color: Color(0xFF57419D),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fondoImagen() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: SizedBox(
        height: 220.0,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(
            image: AssetImage('diseñador/drawable/Productos/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40.0, 0, 10.0),
      child: Column(
        children: [
          Text(
            'Los mejores productos',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            'Porque tu mascota se lo merece',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            margin: EdgeInsets.all(5.0),
                            child: TextField(
                              controller: _searchTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: '¿Qué buscas?',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: 15.0, color: Color(0xFF7f9d9D)),
                              ),
                              onChanged: (text) {
                                text = text.toLowerCase();
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(220, 15, 0, 0),
                            margin: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.search,
                              color: Color(0xFF7f9d9D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconos() {
    return Column(
      children: [
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Alimento";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlimentoHome(
                              petModel: model,
                              tituloDetalle: tituloDetalle,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'diseñador/drawable/Productos/alimento.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Alimento",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Juguetes";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlimentoHome(
                              petModel: model,
                              tituloDetalle: tituloDetalle,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'diseñador/drawable/Productos/juguetes.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Juguetes",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Accesorios";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlimentoHome(
                              petModel: model,
                              tituloDetalle: tituloDetalle,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'assets/images/accesorios.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Accesorios",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Farmacias";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlimentoHome(
                              petModel: model,
                              tituloDetalle: tituloDetalle,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'diseñador/drawable/Productos/farmacias.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Farmacias",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.0,
              height: 115.0,
              child: RaisedButton(
                onPressed: () {
                  String tituloDetalle = "Tiendas";
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlimentoHome(
                              petModel: model,
                              tituloDetalle: tituloDetalle,
                              defaultChoiceIndex: widget.defaultChoiceIndex,
                            )),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // color: Color(0xFFF4F6F8),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: Image.asset(
                        'diseñador/drawable/Productos/tiendas.png',
                        color: Color(0xFF57419D),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Tiendas",
                        style: TextStyle(
                            fontFamily: 'Product Sans',
                            color: Color(0xFF57419D),
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cuerpo() {
    return Column(
      children: <Widget>[
        _titulo(),
        _menu(),
        _searchTextEditingController.text.isEmpty
            ? _iconos()
            : Container(
                height: 120 * double.parse(_resultsList.length.toString()),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Expanded(
                      child: Container(
                        height:
                            120 * double.parse(_resultsList.length.toString()),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _resultsList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return sourceInfo(context, _resultsList[index]);
                            }),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  changePet(otro) {
    setState(() {
      model = otro;
    });

    return otro;
  }

  Widget sourceInfo(BuildContext context, ProductoModel product) {
    // final product = Producto.fromSnapshot(snapshot);

    return InkWell(
      child: Row(
        children: [
          Container(
            height: 100.0,
            width: MediaQuery.of(context).size.width * 0.89,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Aliados')
                    .doc(product.aliadoId)
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      shrinkWrap: true,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        AliadoModel ali =
                            AliadoModel.fromJson(dataSnapshot.data.data());
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlimentoDetalle(
                                    petModel: model,
                                    productoModel: product,
                                    aliadoModel: ali,
                                      defaultChoiceIndex:
                                      widget.defaultChoiceIndex
                                  ),
                                ));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)

                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      product.urlImagen,
                                      height: 77,
                                      width: 66,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, object, stacktrace) {
                                        return Container();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 7.0,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        height: 80.0,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(product.titulo,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF57419D),
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.left),
                                            Flexible(
                                                child: Text(product.dirigido,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.left)),
                                            SizedBox(height: 8.0),
                                            Row(
                                              children: [
                                                Text(
                                                    PetshopApp.sharedPreferences
                                                        .getString(PetshopApp
                                                            .simboloMoneda),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF57419D),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left),
                                                Text(product.precio.toStringAsFixed(2),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF57419D),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
