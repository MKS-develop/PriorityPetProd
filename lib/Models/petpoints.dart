import 'package:cloud_firestore/cloud_firestore.dart';

class PetpointsModel{
  String uid;
  Timestamp createdOn;
  int ppAcumulados;
  int ppCanjeados;
  int ppGenerados;


  PetpointsModel({
    this.uid,
    this.createdOn,
    this.ppAcumulados,
    this.ppCanjeados,
    this.ppGenerados,
  });

  PetpointsModel.fromJson(Map<String, dynamic> json){
    uid = json['uid'];
    createdOn = json['createdOn'];
    ppAcumulados = json['ppAcumulados'];
    ppCanjeados = json['ppCanjeados'];
    ppGenerados = json['ppGenerados'];

  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['createdOn'] = this.createdOn;
    data['ppAcumulados'] = this.ppAcumulados;
    data['ppCanjeados'] = this.ppCanjeados;
    data['ppGenerados'] = this.ppGenerados;

    return data;
  }
}