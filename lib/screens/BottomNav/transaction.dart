// create a statefull widget to display the transactions from the database

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:go_router/go_router.dart';
import '../../utils/default_logger.dart';
import '/functions/functions.dart';
import '/screens/components/empty_list_widget.dart';
import '/utils/date_utils.dart';
import '../../route_management/route_name.dart';
import '../../functions/sqlDatabase.dart';
import '../components/appbar.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        // elevation: 0,
        // backgroundColor: Colors.transparent,
        title: titleLargeText('Transactions', context, color: Colors.white),
        actions: const [ToggleBrightnessButton()],
      ),
      body: const TransactionList(trasnsactionList: null),
    );
  }
}

class TransactionList extends StatefulWidget {
  const TransactionList({this.trasnsactionList});
  final Future<List<Map<String, dynamic>>>? trasnsactionList;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late Future<List<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions =
        widget.trasnsactionList ?? SqlDb().getAll(oredrBy: 'created_at DESC');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactions,
        builder: (context, snapshot) {
          infoLog('$snapshot ${snapshot.connectionState}');
          if (snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else if (snapshot.hasData) {
              return _TransactionListView(snapshot.data ?? []);
            } else {
              return Center(child: titleLargeText('No Data', context));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

class _TransactionListView extends StatefulWidget {
  const _TransactionListView(this.data);
  final List<Map<String, dynamic>> data;

  @override
  State<_TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<_TransactionListView> {
  Map<String, List<Map<String, dynamic>>> data = {};

  @override
  void initState() {
    super.initState();
    getListWithDate();
  }

  getListWithDate() {
    Map<String, List<Map<String, dynamic>>> list = {};
    for (var i = 0; i < widget.data.length; i++) {
      Map<String, dynamic> transaction = widget.data[i];
      String date = ((transaction['created_at']));
      bool condition = list.entries
              .any((item) => item.key.split(' ')[0] == date.split(' ')[0]) ==
          false;
      // warningLog(condition.toString());
      if (condition) {
        list.addAll({
          date: [transaction]
        });
      } else {
        list.entries
            .firstWhere(
                (element) => date.split(' ')[0] == element.key.split(' ')[0])
            .value
            .add(transaction);
      }
    }
    // errorLog(list.toString());
    data = list;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return data.isNotEmpty
        // ?
        ? CustomScrollView(
            slivers: [
              ...data.entries
                  .toList()
                  .map((item) => buildWithHeader(item))
                  .toList(),
            ],
          )
        : const Center(child: EmptyListWidget(text: 'No Transactions'));
  }

  SliverStickyHeader buildWithHeader(
      MapEntry<String, List<Map<String, dynamic>>> items) {
    return SliverStickyHeader.builder(
      builder: (context, state) => buildHeader(context, items),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            Map<String, dynamic> data = jsonDecode(items.value[i]['data']);
            // infoLog(data.toString());
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingDefault),
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(RouteName.tx, extra: data);
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(paddingDefault),
                      // margin: EdgeInsets.only(bottom: paddingDefault),
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                getTheme.colorScheme.primary.withOpacity(0.2),
                            backgroundImage:
                                NetworkImage(data['imageUrl'] ?? ''),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // titleLargeText(data['symbol'] ?? '', context),
                                //richtext for to and toaddress
                                RichText(
                                    text: TextSpan(
                                        text: 'To: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: getTheme
                                                .textTheme.titleLarge?.color),
                                        children: [
                                      TextSpan(
                                          text: data['toAddress'] ?? '',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: getTheme
                                                  .textTheme.titleLarge?.color
                                                  ?.withOpacity(0.5),
                                              fontWeight: FontWeight.bold)),
                                    ])),
                                height10(),
                                capText(
                                    ('🪙 ${data['amount'] ?? ''}').toString(),
                                    context),
                              ],
                            ),
                          ),
                          width10(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PopupMenuButton<String>(
                                surfaceTintColor:
                                    getTheme.brightness == Brightness.dark
                                        ? null
                                        : Colors.white,
                                clipBehavior: Clip.hardEdge,
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'copy',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.copy, size: 15),
                                        width10(),
                                        capText(
                                            'Copy Transaction Hash', context),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'details',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.launch, size: 15),
                                        width10(),
                                        capText('Transaction Details', context),
                                      ],
                                    ),
                                  ),
                                ],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onSelected: (String value) {
                                  if (value == 'copy') {
                                    copyToClipboard(data['hash'] ?? '',
                                        'Transaction Hash Copied');
                                  } else if (value == 'details') {
                                    context.pushNamed(RouteName.tx,
                                        extra: data);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                              capText(
                                  MyDateUtils.formatDate(
                                      items.value[i]['created_at'] ?? '',
                                      'hh:mm a'),
                                  context,
                                  fontSize: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (i < items.value.length - 1)
                      Divider(
                        thickness: 1,
                        color: getTheme.colorScheme.primary.withOpacity(0.2),
                      ),
                  ],
                ),
              ),
            );
          },
          childCount: items.value.length,
        ),
      ),
    );
  }

  Container buildHeader(
      BuildContext context, MapEntry<String, List<Map<String, dynamic>>> item) {
    return Container(
      // height: 60.0,
      color: (Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 101, 115, 122)
          : const Color.fromARGB(255, 238, 238, 238)),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
        child: Text(MyDateUtils.formatDateAsToday(item.key, null, true)),
      ),
    );
  }
}
