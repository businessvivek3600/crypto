import 'package:flutter/material.dart';
import 'package:my_global_tools/utils/default_logger.dart';
import 'package:my_global_tools/utils/picture_utils.dart';
import 'package:my_global_tools/utils/text.dart';
import '../../utils/sized_utils.dart';
import '/screens/components/appbar.dart';

class SwapCoinsPage extends StatefulWidget {
  const SwapCoinsPage({super.key});

  @override
  State<SwapCoinsPage> createState() => _SwapCoinsPageState();
}

class _SwapCoinsPageState extends State<SwapCoinsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        title: titleLargeText('Swap Coins', context, color: Colors.white),
      ),
      body: Container(
        child: ListView(
          children: [
            //create ui for swaping between two coins each coin each tapable and a list of coinq is open to select

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bodyLargeText('Send', context, color: Colors.blueGrey),
                  Row(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.transparent,
                              child: buildCachedImageWithLoading(
                                  'https://s2.coinmarketcap.com/static/img/coins/64x64/52.png,')),
                          width5(),
                          bodyLargeText('BTC', context, color: Colors.blueGrey),
                        ],
                      ),
                      Spacer(),
                      bodyLargeText('0.00000000', context,
                          color: Colors.blueGrey),
                    ],
                  ),
                  //coin image
                  //coin name
                ],
              ),
            ),

            const Text('Swap Coins Page'),
          ],
        ),
      ),
    );
  }
}
