class ChartData {
  int? open_time;
  double? open;
  double? high;
  double? low;
  double? close;
  double? volume;
  int? close_time;
  double? quote_volume;
  int? count;
  double? taker_buy_volume;
  double? taker_buy_quote_volume;
  bool? ignore;

  ChartData({
    this.open_time,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
    this.close_time,
    this.quote_volume,
    this.count,
    this.taker_buy_volume,
    this.taker_buy_quote_volume,
    this.ignore,
  });

  factory ChartData.fromList(List<dynamic> list) {
    return ChartData(
      open_time: list[0] != null ? int.parse(list[0].toString()) : 0,
      open: list[1] != null ? double.parse(list[1].toString()) : 0.0,
      high: list[2] != null ? double.parse(list[2].toString()) : 0.0,
      low: list[3] != null ? double.parse(list[3].toString()) : 0.0,
      close: list[4] != null ? double.parse(list[4].toString()) : 0.0,
      volume: list[5] != null ? double.parse(list[5].toString()) : 0.0,
      close_time: list[6] != null ? int.parse(list[6].toString()) : 0,
      quote_volume: list[7] != null ? double.parse(list[7].toString()) : 0.0,
      count: list[8] != null ? int.parse(list[8].toString()) : 0,
      taker_buy_volume:
          list[9] != null ? double.parse(list[9].toString()) : 0.0,
      taker_buy_quote_volume:
          list[10] != null ? double.parse(list[10].toString()) : 0.0,
      ignore: list[11] != null ? list[11] == '1' : false,
    );
  }

  List<dynamic> toList() {
    return [
      open_time,
      open,
      high,
      low,
      close,
      volume,
      close_time,
      quote_volume,
      count,
      taker_buy_volume,
      taker_buy_quote_volume,
      ignore
    ];
  }
}
