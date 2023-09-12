class CoinModel {
  List<Coin>? coins;

  CoinModel({this.coins});

  CoinModel.fromJson(Map<String, dynamic> json) {
    if (json['coins'] != null) {
      coins = <Coin>[];
      json['coins'].forEach((v) {
        coins!.add(Coin.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coins != null) {
      data['coins'] = coins!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Coin {
  GraphData? graphData;
  String? sId;
  bool? disabled;
  String? coinId;
  String? name;
  String? symbol;
  double? price;
  String? lastUpdated;
  String? imageUrl;
  String? parentWallet;
  String? contractAddress;
  String? lastApiCall;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Coin(
      {this.graphData,
      this.sId,
      this.coinId,
      this.disabled,
      this.name,
      this.symbol,
      this.price,
      this.lastUpdated,
      this.imageUrl,
      this.contractAddress,
      this.parentWallet,
      this.lastApiCall,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Coin.fromJson(Map<String, dynamic> json) {
    graphData = json['graphData'] != null
        ? GraphData.fromJson(json['graphData'])
        : null;
    sId = json['_id'];
    coinId = json['coinId'];
    disabled = json['disabled'];
    name = json['name'];
    contractAddress = json['contractAddress'];
    parentWallet = json['parentWallet'];
    symbol = json['symbol'];
    price = double.parse(json['price'] ?? '0');
    lastUpdated = json['lastUpdated'];
    imageUrl = json['imageUrl'];
    lastApiCall = json['lastApiCall'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (graphData != null) {
      data['graphData'] = graphData!.toJson();
    }
    data['_id'] = sId;
    data['coinId'] = coinId;
    data['disabled'] = disabled;
    data['name'] = name;
    data['contractAddress'] = contractAddress;
    data['parentWallet'] = parentWallet;
    data['symbol'] = symbol;
    data['price'] = price;
    data['lastUpdated'] = lastUpdated;
    data['imageUrl'] = imageUrl;
    data['lastApiCall'] = lastApiCall;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class GraphData {
  OneDay? oneDay;
  OneDay? oneWeek;
  OneDay? oneMonth;
  OneYear? oneYear;

  GraphData({this.oneDay, this.oneWeek, this.oneMonth, this.oneYear});

  GraphData.fromJson(Map<String, dynamic> json) {
    oneDay = json['oneDay'] != null ? OneDay.fromJson(json['oneDay']) : null;
    oneWeek = json['oneWeek'] != null ? OneDay.fromJson(json['oneWeek']) : null;
    oneMonth =
        json['oneMonth'] != null ? OneDay.fromJson(json['oneMonth']) : null;
    oneYear =
        json['oneYear'] != null ? OneYear.fromJson(json['oneYear']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (oneDay != null) {
      data['oneDay'] = oneDay!.toJson();
    }
    if (oneWeek != null) {
      data['oneWeek'] = oneWeek!.toJson();
    }
    if (oneMonth != null) {
      data['oneMonth'] = oneMonth!.toJson();
    }
    if (oneYear != null) {
      data['oneYear'] = oneYear!.toJson();
    }
    return data;
  }
}

class OneDay {
  double? priceChange;
  String? priceChangeColor;

  OneDay({this.priceChange, this.priceChangeColor});

  OneDay.fromJson(Map<String, dynamic> json) {
    priceChange = json['priceChange'];
    priceChangeColor = json['priceChangeColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['priceChange'] = priceChange;
    data['priceChangeColor'] = priceChangeColor;
    return data;
  }
}

class OneYear {
  String? priceChangeColor;

  OneYear({this.priceChangeColor});

  OneYear.fromJson(Map<String, dynamic> json) {
    priceChangeColor = json['priceChangeColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['priceChangeColor'] = priceChangeColor;
    return data;
  }
}
