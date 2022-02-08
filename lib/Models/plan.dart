import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  dynamic descuento, montoAnual, montoMensual, codigoplan;
  String planId, codigo, nombrePlan;
  List<dynamic> detallesBasicos;
  List<dynamic> detallesCompletos;
  List<dynamic> coberturas;


  PlanModel(
      {this.descuento,
        this.montoAnual,
        this.montoMensual,
        this.planId,
        this.codigoplan,
        this.detallesBasicos,
        this.detallesCompletos,
        this.coberturas,
        this.codigo,
        this.nombrePlan,

        });

  PlanModel.fromJson(Map<String, dynamic> json) {
    descuento = json['descuento'];
    montoAnual = json['montoAnual'];
    montoMensual = json['montoMensual'];
    planId = json['planId'];
    codigoplan = json['codigoplan'];
    detallesBasicos = json['detallesBasicos'];
    detallesCompletos = json['detallesCompletos'];
    coberturas = json['coberturas'];
    codigo = json['codigo'];
    nombrePlan = json['nombrePlan'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descuento'] = this.descuento;
    data['montoAnual'] = this.montoAnual;
    data['montoMensual'] = this.montoMensual;
    data['planId'] = this.planId;
    data['codigoplan'] = this.codigoplan;
    data['detallesBasicos'] = this.detallesBasicos;
    data['detallesCompletos'] = this.detallesCompletos;
    data['coberturas'] = this.coberturas;
    data['codigo'] = this.codigo;
    data['nombrePlan'] = this.nombrePlan;


    return data;
  }
}


