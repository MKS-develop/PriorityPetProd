import 'package:cloud_firestore/cloud_firestore.dart';

class DayModel{
  String agendaId;
  Timestamp createdOn, date;
  String fecha;
  List<dynamic> horasDia;
  String promoId;

  DayModel({
    this.agendaId,
    this.createdOn,
    this.fecha,
    this.horasDia,
    this.promoId,
    this.date,
  });

  DayModel.fromJson(Map<String, dynamic> json){
    agendaId = json['agendaId'];
    createdOn = json['createdOn'];
    fecha = json['fecha'];
    horasDia = json['horasDia'];
    promoId = json['promoId'];
    date = json['date'];

  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['agendaId'] = this.agendaId;
    data['createdOn'] = this.createdOn;
    data['fecha'] = this.fecha;
    data['horasDia'] = this.horasDia;
    data['promoId'] = this.promoId;
    data['date'] = this.date;

    return data;
  }
}