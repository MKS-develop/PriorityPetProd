
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String message;
  String messageId;
  String uid;
  String aliadoId;
  Timestamp createdOn;
  
  MessageModel({
    this.message,
    this.messageId,
    this.uid,
    this.aliadoId,
    this.createdOn,
  });

  MessageModel.fromJson(Map<String, dynamic> json){
    message = json['message'];
    messageId = json['messageId'];
    uid = json['uid'];
    aliadoId = json['aliadoId'];
    createdOn = json['createdOn'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['message'] = this.message;
    data['messageId'] = this.messageId;
    data['uid'] = this.uid;
    data['aliadoId'] = this.aliadoId;
    data['createdOn'] = this.createdOn;
    return data;
  }
}