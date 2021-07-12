import 'package:cloud_firestore/cloud_firestore.dart';

class EspecialidadesModel {
  String aliadoId;
 String especialidad;
 String especialidadId;
  String certificado;
  String grupo;
  String hojaProfesional;

  bool busquedaIdividual;

  EspecialidadesModel(
      {    this.aliadoId,
        this.especialidad,
        this.especialidadId,
        this.certificado,
        this.grupo,
        this.hojaProfesional,

      });

  EspecialidadesModel.fromJson(Map<String, dynamic> json) {
    aliadoId = json['aliadoId'];
    especialidad = json['especialidad'];
    especialidadId = json['especialidadId'];
    certificado = json['certificado'];
    grupo = json['grupo'];
    hojaProfesional = json['hojaProfesional'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aliadoId'] = this.aliadoId;
    data['especialidad'] = this.especialidad;
    data['especialidadId'] = this.especialidadId;
    data['certificado'] = this.certificado;
    data['grupo'] = this.grupo;
    data['hojaProfesional'] = this.hojaProfesional;


    return data;
  }
}

