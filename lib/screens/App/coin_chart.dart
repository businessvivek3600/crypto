import 'dart:convert';
import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../functions/sqlDatabase.dart';
import '../BottomNav/transaction.dart';
import '../components/receive_qr_code_widget.dart';
import '/constants/asset_constants.dart';
import '/utils/color.dart';
import '/utils/loader.dart';
import '/utils/picture_utils.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../functions/dio/exception/api_error_handler.dart';
import '../../functions/functions.dart';
import '../../models/base/api_response.dart';
import '../../models/coin_model.dart';
import '../../models/user/user_data_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../route_management/route_name.dart';
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

class _CoinChartPageState extends State<CoinChartPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late String symbol;
  Coin? coin;
  Wallet? wallet;

  @override
  void initState() {
    dio = sl.get<DioClient>();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.index == 0) {
        future(1000, () => SystemChrome.setPreferredOrientations([]));
      } else {
        // SystemChrome.setPreferredOrientations(
        // [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      }
      setState(() {});
    });
    symbol = widget.symbol!.toLowerCase().split('usdt').first;
    try {
      coin = sl
          .get<DashboardProvider>()
          .coinModel!
          .coins!
          .firstWhere((element) => element.symbol!.toLowerCase() == symbol);
      if (coin != null) {
        wallet = sl
            .get<AuthProvider>()
            .user
            .wallet!
            .firstWhere((element) => element.tokenName == coin!.parentWallet);
      }
    } catch (e) {
      errorLog(e.toString(), 'coin chart page');
    }

    // getChartData();
    // getCurrentPrice();
    _tooltip = TooltipBehavior(enable: true);
    _trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);

    SystemChrome.setPreferredOrientations([]);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget tradingViewWidget = TradingViewWidgetHtml(
        cryptoName: widget.symbol!,
        theme: getTheme.brightness == Brightness.light ? 'light' : 'dark');
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.landscape && tabController.index == 0) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
            overlays: []);
        return Scaffold(
            body: SafeArea(
                maintainBottomViewPadding: true,
                left: false,
                right: false,
                top: true,
                bottom: false,
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          height20(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      // tabController.animateTo(1);

                                      SideSheet.right(
                                          width: 350,
                                          sheetColor: Colors.transparent,
                                          body: _LandscapeSheetWidget(
                                              widget: widget,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: titleLargeText(
                                                          'Transactions',
                                                          context,
                                                        ),
                                                      ),
                                                      width10(),
                                                      GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Icon(
                                                              Icons.clear)),
                                                    ],
                                                  ),
                                                  height10(),
                                                  Expanded(
                                                      child: TransactionList(
                                                          trasnsactionList:
                                                              getTransactions())),
                                                ],
                                              )),
                                          context: context);
                                    },
                                    child: assetImages(PNGAssets.history,
                                        width: 30, height: 30)),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          SideSheet.right(
                                              width: 350,
                                              sheetColor: Colors.transparent,
                                              body: _LandscapeSheetWidget(
                                                  widget: widget,
                                                  child: Center(
                                                    child: titleLargeText(
                                                        'Buy ${widget.symbol?.toUpperCase()}',
                                                        context,
                                                        color: Colors.white),
                                                  )),
                                              context: context);
                                        },
                                        child: assetImages(PNGAssets.buy,
                                            width: 30, height: 30)),
                                    height10(),
                                    GestureDetector(
                                        onTap: () {
                                          if (wallet == null) {
                                            Toasts.fToast('Wallet not found');
                                            return;
                                          }
                                          SideSheet.right(
                                              width: 350,
                                              sheetColor: Colors.transparent,
                                              body: _LandscapeSheetWidget(
                                                  widget: widget,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                titleLargeText(
                                                                    'Recieve',
                                                                    context),
                                                          ),
                                                          width10(),
                                                          GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Icon(
                                                                  Icons.clear)),
                                                        ],
                                                      ),
                                                      height10(),
                                                      Expanded(
                                                        child: LayoutBuilder(
                                                            builder: (context,
                                                                bound) {
                                                          infoLog(
                                                              'bound ${bound.maxWidth}');
                                                          infoLog(
                                                              'bound ${bound.maxHeight}');
                                                          return ReceiveQrCodeWidget(
                                                              embeded: true,
                                                              size: Size(
                                                                  bound.maxHeight -
                                                                      120,
                                                                  150),
                                                              walletModel:
                                                                  wallet!);
                                                        }),
                                                      )
                                                    ],
                                                  )),
                                              context: context);
                                        },
                                        child: assetImages(PNGAssets.recieve,
                                            width: 30, height: 30)),
                                    height10(),
                                    GestureDetector(
                                        onTap: _sendCoin,
                                        child: assetImages(PNGAssets.send,
                                            width: 30, height: 30)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          height20(),
                        ],
                      ),
                    ),
                    Expanded(child: tradingViewWidget),
                  ],
                )));
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
      return buildPortraitView(context, tradingViewWidget);
    });
  }

  Scaffold buildPortraitView(BuildContext context, Widget tradingViewWidget) {
    return Scaffold(
      appBar: buildCustomAppBar(
          title: titleLargeText('Graph View', context, color: Colors.white),
          height: kToolbarHeight + 20,
          actions: [
            ToggleBrightnessButton(
              onChange: (mode) {
                setState(() {});
              },
            ),
            // PopupMenuButton(
            //   surfaceTintColor: Colors.white,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   shadowColor: getTheme.brightness == Brightness.light
            //       ? Colors.grey
            //       : null,
            //   offset: const Offset(0, 30),
            //   itemBuilder: (_) => intervals
            //       .map((e) => PopupMenuItem(
            //             textStyle: const TextStyle(
            //                 color: Colors.black,
            //                 textBaseline: TextBaseline.alphabetic),
            //             value: e,
            //             child: capText(e, context),
            //           ))
            //       .toList(),
            //   onSelected: (value) {
            //     setState(() {
            //       interval = value.toString();
            //     });
            //     getChartData();
            //   },
            //   child: const Icon(Icons.more_vert),
            // ),
            // width10()
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: TabBar(
                  controller: tabController,
                  physics: const BouncingScrollPhysics(),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(0),
                  // indicatorWeight: 0,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(text: 'Chart'),
                    Tab(text: 'Transactions')
                  ]))),
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ListView(children: [SizedBox(height: 300, child: tradingViewWidget)]),
          TransactionList(trasnsactionList: getTransactions())
        ],
      ),
      // body: buildSfChart(),
      bottomNavigationBar:
          tabController.index == 0 ? _buildBottomBar(context) : null,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions() =>
      SqlDb().getAll(oredrBy: 'created_at DESC').then((value) => value
          .where((item) =>
              (jsonDecode(item['data']))['symbol'] == symbol.toUpperCase())
          .toList());
  void _sendCoin() {
    infoLog('wallet ${wallet?.toJson()}');

    if (coin == null) {
      Toasts.fToast('Coin not found');
      return;
    } else if (wallet == null) {
      Toasts.fToast('Wallet not found');
      return;
    } else {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      context.pushNamed(RouteName.sendCoin,
          extra: {"wallet": wallet!.toJson(), "coin": coin!.toJson()});
    }
  }

  ListView buildSfChart() {
    return ListView(
      children: [
        Card(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: getTheme.brightness == Brightness.light
              ? Colors.grey.withOpacity(0.2)
              : Colors.transparent,
          elevation: 10,
          margin: const EdgeInsets.all(0),
          child: Container(
              height: (getWidth > getHeight ? getHeight : getWidth) -
                  kToolbarHeight -
                  kBottomNavigationBarHeight,
              padding: const EdgeInsets.only(right: 8.0),
              child:
                  loadingGraph ? loaderWidget(radius: 10) : buildSfChartData()),
        ),

        //     //
        // Container(height: 300, child: buildCandleStickChart()),
        //     // Spacer(),
      ],
    );
    //
  }

  Padding _buildBottomBar(BuildContext context) {
    return Padding(
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
              onPressed: _sendCoin,
              label: bodyLargeText('Send', context, color: Colors.white),
              icon: assetImages(PNGAssets.send, width: 20, height: 20),
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
                  if (wallet == null) {
                    Toasts.fToast('Wallet not found');
                    return;
                  }
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    builder: (context) {
                      return ReceiveQrCodeWidget(walletModel: wallet!);
                    },
                  );
                },
                label: bodyLargeText('Recive', context, color: Colors.white),
                icon: assetImages(PNGAssets.recieve, width: 20, height: 20)),
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
              icon: assetImages(PNGAssets.buy, width: 20, height: 20),
            ),
          ),
        ],
      ),
    );
  }

  late DioClient dio;
  List<ChartData> data = [];
  List<Candle> candles = [];
  late TooltipBehavior _tooltip;
  TrackballBehavior? _trackballBehavior;
  bool loadingGraph = false;
  bool loadingPrice = false;
  double price = 0;
  String interval = '1m';
  String? priceErr;
  final intervals = ['1m', '5m', '30m', '1h', '12h', '1d', '1w', '1M'];

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

class _LandscapeSheetWidget extends StatelessWidget {
  const _LandscapeSheetWidget({
    super.key,
    required this.widget,
    required this.child,
  });

  final CoinChartPage widget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: paddingDefault,
        left: paddingDefault,
        top: paddingDefault,
        bottom: paddingDefault,
      ),
      padding: EdgeInsets.all(paddingDefault),
      decoration: BoxDecoration(
          color: getTheme.brightness == Brightness.light
              ? Colors.white
              : Colors.blueGrey
                  // .shade600
                  .darken(60),
          borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}

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
  <div id="tradingview_a0483"></div>
  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
  new TradingView.widget(
  {
  "autosize": true,
  "symbol": "$name",
  "interval": "30",
  "timezone": "Asia/Kolkata",
  "theme": "$theme",
  "style": "1",
  "locale": "in",
  "enable_publishing": false,
  "allow_symbol_change": true,
  "details": false,
  "container_id": "tradingview_a0483"
}
  );
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
