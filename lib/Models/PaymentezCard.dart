class PaymentezCardModel {
  final int result_size;
  final List<Data> cards;

  PaymentezCardModel({this.result_size, this.cards});

  factory PaymentezCardModel.fromJson(Map<String, dynamic> parsedJson){

    var list = parsedJson['cards'] as List;
    print(list.runtimeType);
    List<Data> dataList = list.map((i) => Data.fromJson(i)).toList();


    return PaymentezCardModel(
        result_size: parsedJson['result_size'],
        cards: dataList
    );
  }
}

class Data {
  final String bin, status, token, holder_name, expiry_year, expiry_month, type, number, transaction_reference;

  Data({this.bin, this.expiry_month, this.expiry_year, this.holder_name, this.number, this.status, this.token, this.type, this.transaction_reference});

  factory Data.fromJson(Map<String, dynamic> parsedJson){
    return Data(
        bin:parsedJson['bin'],
        expiry_month:parsedJson['expiry_month'],
        expiry_year:parsedJson['expiry_year'],
        type:parsedJson['type'],
        holder_name:parsedJson['holder_name'],
        number:parsedJson['number'],
        status:parsedJson['status'],
        token:parsedJson['token'],
        transaction_reference:parsedJson['transaction_reference'],
    );
  }
}


// class PaymentezCardModel {
//   final String bin, status, token, holder_name, expiry_year, expiry_month, type, number;
//   // final List<CulqiResultModel> outcome;
//
//   PaymentezCardModel(
//       {this.bin, this.expiry_month, this.expiry_year, this.holder_name, this.number, this.status, this.token, this.type});
//
//   factory PaymentezCardModel.fromJson(Map<String, dynamic> json) {
//     // var list = json['data'] as List;
//     // List<CulqiResultModel> data = list.map((i) => CulqiResultModel.fromJson(i)).toList();
//     return PaymentezCardModel(
//         bin: json['bin'],
//         expiry_year: json['expiry_year'],
//         status: json['status'],
//         expiry_month: json['expiry_month'],
//         type: json['type'],
//         token: json['token'],
//         number: json['number'],
//         holder_name: json['holder_name']
//
//     );
//
//   }
// }


class PaymentezResultModel {
  final String type, user_message, merchant_message;

  PaymentezResultModel({this.type, this.user_message, this.merchant_message});

  factory PaymentezResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentezResultModel(
      type: json['type'],
      user_message: json['user_message'],
      merchant_message: json['merchant_message'],
    );
  }
}





