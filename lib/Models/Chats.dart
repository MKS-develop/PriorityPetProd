import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel{
  String aliadoId;
  String uid;
  Timestamp createdOn;
  String chatId;
  bool status;
  
  ChatsModel({
    this.aliadoId,
    this.uid,
    this.createdOn,
    this.chatId,
    this.status,
  });

  ChatsModel.fromJson(Map<String, dynamic> json){
    aliadoId = json['aliadoId'];
    uid = json['uid'];
    createdOn = json['createdOn'];
    chatId = json['chatId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['aliadoId'] = this.aliadoId;
    data['uid'] = this.uid;
    data['createdOn'] = this.createdOn;
    data['chatId'] = this.chatId;
    data['status'] = this.status;
    return data;
  }
}