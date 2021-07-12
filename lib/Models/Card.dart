import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel{
  String cardBrand, cardId, cardNumber, cardToken, expiryDate;
  Timestamp createdOn;

  CardModel({
    this.cardBrand,
    this.cardId,
    this.cardNumber,
    this.cardToken,
    this.expiryDate,
    this.createdOn,


  });

  CardModel.fromJson(Map<String, dynamic> json){
    cardBrand = json['cardBrand'];
    cardId = json['cardId'];
    cardNumber = json['cardNumber'];
    cardToken = json['cardToken'];
    expiryDate = json['expiryDate'];
    createdOn = json['createdOn'];


  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cardBrand'] = this.cardBrand;
    data['cardId'] = this.cardId;
    data['cardNumber'] = this.cardNumber;
    data['cardToken'] = this.cardToken;
    data['expiryDate'] = this.expiryDate;
    data['createdOn'] = this.createdOn;


    return data;
  }




}