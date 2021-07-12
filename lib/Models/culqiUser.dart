


class CulqiUserModel {
  final String id, card_brand, state, object;
  // final List<CulqiResultModel> outcome;

  CulqiUserModel(
      {this.id, this.card_brand, this.state, this.object});

  factory CulqiUserModel.fromJson(Map<String, dynamic> json) {
    // var list = json['data'] as List;
    // List<CulqiResultModel> data = list.map((i) => CulqiResultModel.fromJson(i)).toList();
    return CulqiUserModel(
        id: json['id'],
        // outcome: data,
        card_brand: json['card_brand'],
        state: json['state'],
        object: json['object']);
  }
}


class CulqiResultModel {
  final String type, user_message, merchant_message;

  CulqiResultModel({this.type, this.user_message, this.merchant_message});

  factory CulqiResultModel.fromJson(Map<String, dynamic> json) {
    return CulqiResultModel(
      type: json['type'],
      user_message: json['user_message'],
      merchant_message: json['merchant_message'],
    );
  }
}





