import '/utils/default_logger.dart';

class UserData {
  bool? isAdmin;
  String? username;
  double? walletBalance;
  String? sId;
  List<Wallet>? wallet;
  String? createdAt;
  String? updatedAt;
  int? iV;

  UserData(
      {this.isAdmin,
      this.username,
      this.walletBalance,
      this.sId,
      this.wallet,
      this.createdAt,
      this.updatedAt,
      this.iV});

  UserData.fromJson(Map<String, dynamic> json) {
    warningLog(json.toString());
    isAdmin = json['isAdmin'];
    username = json['username'];
    walletBalance = json['walletBalance'];
    sId = json['_id'];
    if (json['wallets'] != null) {
      wallet = <Wallet>[];
      json['wallets'].forEach((v) {
        wallet!.add(Wallet.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isAdmin'] = isAdmin;
    data['username'] = username;
    data['walletBalance'] = walletBalance;
    data['_id'] = sId;
    if (wallet != null) {
      data['wallets'] = wallet!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Wallet {
  String? sId;
  String? walletId;
  String? walletAddress;
  String? walletXpub;
  String? tokenName;
  double? balance;
  String? currency;
  String? privateKey;
  String? imageUrl;
  List<Transaction>? transactions;
  String? createdAt;

  Wallet(
      {this.sId,
      this.walletId,
      this.walletAddress,
      this.walletXpub,
      this.tokenName,
      this.balance,
      this.currency,
      this.privateKey,
      this.imageUrl,
      this.transactions,
      this.createdAt});

  Wallet.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    walletId = json['walletId'];
    walletAddress = json['walletAddress'];
    walletXpub = json['walletXpub'];
    tokenName = json['tokenName'];
    balance = double.parse((json['balance'] ?? 0).toString());
    currency = json['currency'];
    privateKey = json['privateKey'];
    imageUrl = json['imageUrl'];
    if (json['transactions'] != null) {
      transactions = <Transaction>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transaction.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['walletId'] = walletId;
    data['walletAddress'] = walletAddress;
    data['walletXpub'] = walletXpub;
    data['tokenName'] = tokenName;
    data['balance'] = balance;
    data['currency'] = currency;
    data['privateKey'] = privateKey;
    data['imageUrl'] = imageUrl;
    if (transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    return data;
  }
}

class Transaction {
  String? txId;
  String? txFrom;
  String? txTo;
  String? txHash;
  String? txType;
  double? txAmount;
  double? txFee;
  String? txToken;
  int? txStatus;
  String? createdAt;

  Transaction(
      {this.txId,
      this.txFrom,
      this.txTo,
      this.txHash,
      this.txType,
      this.txAmount,
      this.txFee,
      this.txToken,
      this.txStatus,
      this.createdAt});

  Transaction.fromJson(Map<String, dynamic> json) {
    txId = json['txId'];
    txFrom = json['txFrom'];
    txTo = json['txTo'];
    txHash = json['txHash'];
    txType = json['txType'];
    txAmount = (json['txAmount'] ?? 0).toDouble();
    txFee = (json['txFee'] ?? 0).toDouble();
    txToken = json['txToken'];
    txStatus = json['txStatus'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['txId'] = txId;
    data['txFrom'] = txFrom;
    data['txTo'] = txTo;
    data['txHash'] = txHash;
    data['txType'] = txType;
    data['txAmount'] = txAmount;
    data['txFee'] = txFee;
    data['txToken'] = txToken;
    data['txStatus'] = txStatus;
    data['createdAt'] = createdAt;
    return data;
  }
}
