import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_global_tools/screens/components/empty_list_widget.dart';
import 'package:my_global_tools/utils/color.dart';
import 'package:my_global_tools/utils/loader.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../functions/dio/exception/api_error_handler.dart';
import '../../functions/functions.dart';
import '../../models/base/api_response.dart';
import '../components/appbar.dart';
import '/functions/dio/dio_client.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/default_logger.dart';
import '/utils/my_toasts.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/chart_data_model.dart';
import '../../repo_injection.dart';

class CoinChartPage extends StatefulWidget {
  const CoinChartPage({Key? key, this.symbol}) : super(key: key);
  final String? symbol;
  @override
  _CoinChartPageState createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  late DioClient dio;
  List<ChartData> data = [];
  List<Candle> candles = [];
  late TooltipBehavior _tooltip;
  late bool _enableSolidCandle;
  late bool _toggleVisibility;
  TrackballBehavior? _trackballBehavior;
  bool loadingGraph = false;
  bool loadingPrice = false;
  double price = 0;
  String interval = '1m';
  String? priceErr;
  final intervals = [
    '1m',
    // '3m',
    '5m',
    // '15m',
    '30m',
    '1h',
    // '2h',
    // '4h',
    // '6h',
    // '8h',
    '12h',
    '1d',
    // '3d',
    '1w',
    '1M',
  ];
  @override
  void initState() {
    dio = sl.get<DioClient>();
    // getChartData();
    // getCurrentPrice();
    _tooltip = TooltipBehavior(enable: true);
    _trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);
    _enableSolidCandle = true;
    _toggleVisibility = true;
    super.initState();
  }

  Future<ApiResponse> hitApi(String url) async {
    try {
      Response response = await dio.get(url);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<void> getChartData() async {
    setState(() {
      loadingGraph = true;
    });
    ApiResponse apiResponse = await hitApi(
        'https://api.binance.com/api/v3/klines?symbol=${widget.symbol?.toUpperCase()}&interval=$interval');
    await future(2000);
    if (apiResponse.response != null) {
      if (apiResponse.response!.statusCode == 200) {
        data.clear();
        final List<ChartData> chartDataList = [];
        for (final List<dynamic> item in apiResponse.response!.data) {
          chartDataList.add(ChartData.fromList(item));
        }
        candles = (apiResponse.response!.data as List<dynamic>)
            .map((e) => Candle.fromJson(e))
            .toList()
            .reversed
            .toList();
        data = chartDataList;
        Toasts.fToast('${data.length} Data loaded');
      } else {
        errorLog(apiResponse.response!.data.toString(), 'getChartData');
        if (apiResponse.response!.statusMessage != null) {
          Toasts.fToast(apiResponse.response!.statusMessage.toString());
        }
      }
    }
    // data = createSamples(30);
    setState(() {
      loadingGraph = false;
    });
  }

  Future<void> getCurrentPrice() async {
    setState(() {
      loadingPrice = true;
    });
    ApiResponse apiResponse = await hitApi(
        'https://api.binance.com/api/v3/ticker/price?symbol=${widget.symbol?.toUpperCase()}');
    priceErr = null;
    if (apiResponse.response != null) {
      if (apiResponse.response!.statusCode == 200) {
        price = double.parse(apiResponse.response!.data['price'].toString());
      } else {
        errorLog(apiResponse.response!.data.toString(), 'getCurrentPrice');
        priceErr = 'eooeh';
      }
    } else {
      priceErr = 'eooeh';
    }
    // data = createSamples(30);
    setState(() {
      loadingPrice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return TradingViewWidgetHtml(cryptoName: widget.symbol!);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: buildCustomAppBar(
            title: titleLargeText('Graph View', context, color: Colors.white),
            height: kToolbarHeight + 40,
            actions: [
              ToggleBrightnessButton(
                onChange: (mode) {
                  setState(() {});
                },
              ),
              PopupMenuButton(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: getTheme.brightness == Brightness.light
                    ? Colors.grey
                    : null,
                offset: const Offset(0, 30),
                itemBuilder: (_) => intervals
                    .map((e) => PopupMenuItem(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              textBaseline: TextBaseline.alphabetic),
                          value: e,
                          child: capText(e, context),
                        ))
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    interval = value.toString();
                  });
                  getChartData();
                },
                child: const Icon(Icons.more_vert),
              ),
              width10()
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: TabBar(
                    physics: const BouncingScrollPhysics(),
                    // indicator: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(10),
                    //   color: getTheme.brightness == Brightness.light
                    //       ? Colors.grey.withOpacity(0.8)
                    //       : Colors.grey.withOpacity(0.8),
                    // ),

                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(0),
                    // indicatorWeight: 0,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(
                        text: 'Chart',
                      ),
                      Tab(
                        text: 'Transactions',
                      ),
                    ]))),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                Expanded(
                    flex: 2,
                    child: TradingViewWidgetHtml(
                      cryptoName: widget.symbol!,
                      theme: getTheme.brightness == Brightness.light
                          ? 'light'
                          : 'dark',
                    )),
                const Spacer(flex: 1),
              ],
            ),
            Column(
              children: [
                Expanded(
                    flex: 3,
                    child: TradingViewWidgetHtml(
                      cryptoName: widget.symbol!,
                      theme: getTheme.brightness == Brightness.light
                          ? 'light'
                          : 'dark',
                    )),
                const Spacer(flex: 1),
              ],
            ),
          ],
        ),
        // body: ListView(
        //   children: [
        //     Card(
        //       surfaceTintColor: Colors.transparent,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       shadowColor: getTheme.brightness == Brightness.light
        //           ? Colors.grey.withOpacity(0.2)
        //           : Colors.transparent,
        //       elevation: 10,
        //       margin: const EdgeInsets.all(0),
        //       child: Container(
        //           height: (getWidth > getHeight ? getHeight : getWidth) -
        //               kToolbarHeight -
        //               kBottomNavigationBarHeight,
        //           padding: const EdgeInsets.only(right: 8.0),
        //           child: loadingGraph
        //               ? loaderWidget(radius: 10)
        //               : buildSfChartData()),
        //     ),

        //     //
        //     // Container(height: 300, child: buildCandleStickChart()),
        //     // Spacer(),
        //   ],
        // )
        //

        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(paddingDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //send button
              SizedBox(
                height: 45,
                child: FloatingActionButton.extended(
                  backgroundColor: greenLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () {
                    //
                  },
                  label: bodyLargeText('Send', context, color: Colors.white),
                  icon: Transform.rotate(
                      angle: -pi / 4,
                      child: const Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: Colors.white,
                      )),
                ),
              ),

              //recive button
              width10(),
              SizedBox(
                height: 45,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () {
                    //
                  },
                  label: bodyLargeText('Recive', context, color: Colors.white),
                  icon: const Icon(
                    Icons.download_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),

              //buy button
              width10(),
              SizedBox(
                height: 45,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () {
                    //
                  },
                  label: bodyLargeText('Buy', context, color: Colors.white),
                  icon: const Icon(
                    Icons.currency_exchange,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCandleStickChart() {
    return Candlesticks(
      candles: candles,
      actions: [
        ToolBarAction(
          child: const Icon(Icons.refresh),
          onPressed: () {
            getChartData();
          },
        ),
      ],
    );
  }

  Widget buildSfChartData() {
    return Stack(
      children: [
        SfCartesianChart(
          title: ChartTitle(
            text: '${widget.symbol?.toUpperCase()} Chart',
            textStyle: const TextStyle(fontSize: 10),
          ),
          primaryXAxis: DateTimeAxis(
            dateFormat: interval == '1s'
                ? DateFormat.ms()
                : interval.contains('m')
                    // ? DateFormat.Hm()
                    // : interval == '1h'
                    ? DateFormat.Hm()
                    : interval.contains('h')
                        ? DateFormat.Hm()
                        : interval.contains('d')
                            ? DateFormat.Md()
                            : interval.contains('w')
                                ? DateFormat.MEd()
                                : interval.contains('M')
                                    ? DateFormat.yMMM()
                                    : DateFormat.y(),
            interval: 1,
            // intervalType: DateTimeIntervalType.months,
            // minimum: DateTime(2016),
            // maximum: DateTime(2016, 10),
            // autoScrollingMode: AutoScrollingMode.start,
            // autoScrollingDelta: 10,
            // autoScrollingDeltaType: DateTimeIntervalType.days,
            labelStyle: const TextStyle(fontSize: 8),
            majorGridLines: const MajorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: const TextStyle(fontSize: 8),
            // minimum: 140,
            // maximum: 60,
            // interval: 20,
            // labelFormat: r'${value}',
            // axisLine: const AxisLine(width: 0),
          ),
          // primaryYAxis:
          // NumericAxis(minimum: 0, maximum: 40, interval: 10),
          tooltipBehavior: _tooltip,
          plotAreaBorderWidth: 0,
          trackballBehavior: _trackballBehavior,
          isTransposed: false,
          enableAxisAnimation: true,
          enableMultiSelection: true,
          series: <ChartSeries<ChartData, DateTime>>[
            if (data.isNotEmpty)
              CandleSeries<ChartData, DateTime>(
                showIndicationForSameValues: true,
                enableSolidCandles: true,
                sortingOrder: SortingOrder.ascending,
                dataSource: data.sublist((data.length - 20).floor()),
                xValueMapper: (ChartData data, _) =>
                    DateTime.fromMillisecondsSinceEpoch(data.open_time!),
                lowValueMapper: (ChartData data, _) => data.low,
                highValueMapper: (ChartData data, _) => data.high,
                openValueMapper: (ChartData data, _) => data.open,
                closeValueMapper: (ChartData data, _) => data.close,
                name: 'Gold',
                bearColor: const Color.fromRGBO(8, 142, 255, 1),
                bullColor: const Color.fromRGBO(255, 50, 50, 1),
              ),
          ],
          loadMoreIndicatorBuilder: getLoadMoreViewBuilder,
        ),
        Positioned(
            right: paddingDefault,
            top: paddingDefault,
            child: GestureDetector(
              onTap: () => getCurrentPrice(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      text: priceErr != null
                          ? 'Price error'
                          : '\$${price.toStringAsFixed(5)}',
                      style: TextStyle(
                          color: priceErr != null ? Colors.red : Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  width5(),
                  loadingPrice ? loaderWidget(radius: 5) : const SizedBox(),
                  !loadingPrice && priceErr != null
                      ? const Icon(
                          Icons.refresh,
                          color: redDark,
                          size: 15,
                        )
                      : const SizedBox(),
                ],
              ),
            ))
      ],
    );
  }

  Widget getLoadMoreViewBuilder(
      BuildContext context, ChartSwipeDirection direction) {
    infoLog(direction.toString(), 'getLoadMoreViewBuilder');
    // if (direction == ChartSwipeDirection.end) {
    return FutureBuilder(
      future: getChartData(),

      /// Adding data by updateDataSource method
      builder: (BuildContext futureContext, AsyncSnapshot snapShot) {
        return snapShot.connectionState != ConnectionState.done
            ? const CircularProgressIndicator()
            : SizedBox.fromSize(size: Size.zero);
      },
    );
    // } else {
    //   return SizedBox.fromSize(size: Size.zero);
    // }
  }
}

ChartData chartData = ChartData(
  open_time: 1650099200,
  open: 100.0,
  high: 105.0,
  low: 95.0,
  close: 102.0,
  volume: 100000,
  close_time: 1650099300,
  quote_volume: 10000000,
  count: 100,
  taker_buy_volume: 50000,
  taker_buy_quote_volume: 5000000,
);

List<ChartData> createSamples(int count) {
  List<ChartData> samples = [];
  for (int i = 0; i < count; i++) {
    ChartData chartData = ChartData(
      open_time: 1650099200 + (i * 1000),
      open: Random().nextDouble() * 100,
      high: Random().nextDouble() * 100,
      low: Random().nextDouble() * 100,
      close: Random().nextDouble() * 100,
      volume: Random().nextDouble() * 100000,
      close_time: 1650099300 + (i * 1000),
      quote_volume: Random().nextDouble() * 10000000,
      count: i,
      taker_buy_volume: Random().nextDouble() * 50000,
      taker_buy_quote_volume: Random().nextDouble() * 5000000,
    );
    samples.add(chartData);
  }
  return samples;
}

class TradingViewWidgetHtml extends StatefulWidget {
  const TradingViewWidgetHtml({
    required this.cryptoName,
    super.key,
    this.theme,
  });

  final String cryptoName;
  final String? theme;
  @override
  State<TradingViewWidgetHtml> createState() => _TradingViewWidgetHtmlState();
}

class _TradingViewWidgetHtmlState extends State<TradingViewWidgetHtml> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color.fromARGB(0, 2, 1, 1))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('progress');
          },
          onPageStarted: (String url) {
            debugPrint('started');
          },
          onPageFinished: (String url) {
            debugPrint('finished');
          },
          onNavigationRequest: (NavigationRequest request) {
            infoLog('onNavigationRequest : ${request.url}');
            return NavigationDecision.prevent;
          },
          onUrlChange: (UrlChange change) async {
            infoLog('url change to ${change.url}');
          },
        ),
      )
      ..enableZoom(true)
      ..loadHtmlString(CryptoNameDataSource.cryptoNameAndSource(
          widget.cryptoName,
          theme: widget.theme));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}

class CryptoNameDataSource {
  static String binanceSourceEuro(String cryptoName) {
    return 'BINANCE:${cryptoName}EUR';
  }

  static String cryptoNameAndSource(String name,
      {String source = 'BINANCE', String? theme = 'light'}) {
    return '''
<!-- TradingView Widget BEGIN -->
<div class="tradingview-widget-container">
  <div class="tradingview-widget-container__widget"></div>
  <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js" async>
  {
  "autosize": true,
  "symbol": "$name",
  "interval": "1",
  "timezone": "Asia/Kathmandu",
  "theme": "$theme",
  "style": "30",
  "locale": "in",
  "enable_publishing": false,
  "allow_symbol_change": true,
  "withdateranges": true,
  "hide_side_toolbar": false,
  "details": false,
  "hotlist": false,
  "calendar": false,
  "show_popup_button": true,
  "popup_width": "1000",
  "popup_height": "650"
}
  </script>
</div>
<!-- TradingView Widget END -->

''';
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>
<div class="tradingview-widget-container">
<div id="tradingview_4418d">
</div>
<div class="tradingview-widget-copyright">
<a href="https://www.tradingview.com/" rel="noopener nofollow" target="_blank">
<span class="blue-text">Track all markets on TradingView
</span>
</a>
</div>
<script type="text/javascript" src="https://s3.tradingview.com/tv.js">
</script>
<script type="text/javascript">
new TradingView.widget({
  "width": "100%",
  "height": 1180,
  "symbol": "$name",
  "interval": "30",
  "timezone": "Etc/UTC",
  "theme": "dark",
  "style": "1",
  "locale": "en",
  "toolbar_bg": "#121536",
  "backgroundColor": "rgba(18, 21, 54, 1)",
  "enable_publishing": false,
  "save_image": false,
  "container_id": "tradingview_4418d"
  });
</script>
</div>
</body>
</html>''';
  }
}
