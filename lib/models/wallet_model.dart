
class WalletModel {
  bool? disabled;
  String? sId;
  String? name;
  String? symbol;
  String? imageUrl;
  String? parentWallet;
  String? createdAt;
  int? iV;
  String? updatedAt;

  WalletModel(
      {this.disabled,
      this.sId,
      this.name,
      this.symbol,
      this.imageUrl,
      this.parentWallet,
      this.createdAt,
      this.iV,
      this.updatedAt});

  WalletModel.fromJson(Map<String, dynamic> json) {
    disabled = json['disabled'];
    sId = json['_id'];
    name = json['name'];
    symbol = json['symbol'];
    imageUrl = json['imageUrl'];
    parentWallet = json['parentWallet'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['disabled'] = disabled;
    data['_id'] = sId;
    data['name'] = name;
    data['symbol'] = symbol;
    data['imageUrl'] = imageUrl;
    data['parentWallet'] = parentWallet;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
