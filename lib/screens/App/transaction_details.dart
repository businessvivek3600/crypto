import 'package:flutter/material.dart';
import 'package:my_global_tools/widgets/app_web_view_page.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, this.data});
  final Map<String, dynamic>? data;
  @override
  Widget build(BuildContext context) {
    return WebViewExample(
      url: data?['url'] ?? '',
      // url: 'https://onramp.money/main/buy/?appId=1',
      enableSearch: false,
      allowBack: true,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Hash:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                '0xab9c33368bcdb60c4d5bd87278325e8fc1d99a4d2aefd6783a36da2ea5708132'),
            SizedBox(height: 16.0),
            Text(
              'Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Success'),
            SizedBox(height: 16.0),
            Text(
              'Block:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('4273343'),
            SizedBox(height: 16.0),
            Text(
              'Block Confirmations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('7'),
            SizedBox(height: 16.0),
            Text(
              'Timestamp:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1 min ago (Sep-12-2023 11:00:48 AM +UTC)'),
            SizedBox(height: 16.0),
            Text(
              'From:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('0x8D1cb7AFCbDB1A130E6146cA87706E0721b39786'),
            SizedBox(height: 16.0),
            Text(
              'To:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('0x79a8c0bDdb40Efbf0B461F0403f9A148f0d6a800'),
            SizedBox(height: 16.0),
            Text(
              'Value:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('0.00000001 ETH (\$0.00)'),
            SizedBox(height: 16.0),
            Text(
              'Transaction Fee:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('0.000249630408027 ETH (\$0.00)'),
            SizedBox(height: 16.0),
            Text(
              'Gas Price:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('11.887162287 Gwei (0.000000011887162287 ETH)'),
            SizedBox(height: 16.0),
            Text(
              'More Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Click to show more'),
            SizedBox(height: 16.0),
            Text(
              'A transaction is a cryptographically signed instruction that changes the blockchain state. Block explorers track the details of all transactions in the network. Learn more about transactions in our Knowledge Base.',
            ),
          ],
        ),
      ),
    );
  }
}
