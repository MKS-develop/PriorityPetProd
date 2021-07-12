import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  int descuento, montoAnual, montoMensual, codigoplan;
  String planid;
  List<dynamic> detallesBasicos;
  List<dynamic> detallesCompletos;


  PlanModel(
      {this.descuento,
        this.montoAnual,
        this.montoMensual,
        this.planid,
        this.codigoplan,
        this.detallesBasicos,
        this.detallesCompletos,

        });

  PlanModel.fromJson(Map<String, dynamic> json) {
    descuento = json['descuento'];
    montoAnual = json['montoAnual'];
    montoMensual = json['montoMensual'];
    planid = json['planid'];
    codigoplan = json['codigoplan'];
    detallesBasicos = json['detallesBasicos'];
    detallesCompletos = json['detallesCompletos'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descuento'] = this.descuento;
    data['montoAnual'] = this.montoAnual;
    data['montoMensual'] = this.montoMensual;
    data['planid'] = this.planid;
    data['codigoplan'] = this.codigoplan;
    data['detallesBasicos'] = this.detallesBasicos;
    data['detallesCompletos'] = this.detallesCompletos;


    return data;
  }
}


