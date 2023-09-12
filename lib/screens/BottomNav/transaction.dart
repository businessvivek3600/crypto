// create a statefull widget to display the transactions from the database

import 'dart:convert';

import 'package:elegant_notification/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_global_tools/utils/default_logger.dart';
import '../../functions/sqlDatabase.dart';
import '/route_management/route_name.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';

import '../../functions/functions.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // elevation: 0,
        title: titleLargeText('Transactions', context, color: Colors.white),
        actions: const [ToggleBrightnessButton()],
      ),
      body: _TransactionBody(),
    );
  }
}

class _TransactionBody extends StatefulWidget {
  const _TransactionBody({super.key});

  @override
  State<_TransactionBody> createState() => _TransactionBodyState();
}

class _TransactionBodyState extends State<_TransactionBody> {
  late Future<List<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = SqlDb().getAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error'));
                  } else if (snapshot.hasData) {
                    Map<String, dynamic> transaction = snapshot.data![index];
                    infoLog(transaction.toString());
                    Map<String, dynamic> data = jsonDecode(transaction['data']);
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(paddingDefault),
                          // margin: EdgeInsets.only(bottom: paddingDefault),
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
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
                                    capText(data['toAddress'] ?? '', context),
                                    capText((data['amount'] ?? '').toString(),
                                        context),
                                  ],
                                ),
                              ),
                              width10(),
                              IconButton(
                                onPressed: () {
                                  // SqlDb().delete(transaction['id']);
                                  // setState(() {
                                  //   _transactions = SqlDb().getAll();
                                  // });
                                },
                                icon: const Icon(
                                  Icons.launch,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < snapshot.data!.length - 1)
                          Divider(
                            thickness: 1,
                            color:
                                getTheme.colorScheme.primary.withOpacity(0.2),
                          ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No Data'));
                  }
                });
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
  void didUpdateWidget(covariant _TransactionBody oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // @override
}
