import 'dart:math';

import 'package:flutter/cupertino.dart';
import '/models/coin_model.dart';
import '/utils/sp_utils.dart';
import '/constants/api_const.dart';
import '/functions/repositories/wallet_repo.dart';
import '/models/recent_users.dart';
import '/utils/api_handler_utils.dart';
import '../utils/my_toasts.dart';
import '../widgets/MultiStageButton.dart';
import '/functions/functions.dart';

import '../utils/default_logger.dart';
import 'connectivity_provider.dart';

class WalletProvider extends ChangeNotifier {
  final WalletRepo walletRepo;
  WalletProvider({required this.walletRepo});
  static const String tag = 'WalletProvider';
  List<int> uniqueNumbers = [];
  List<String> options = [];
  Random random = Random();
  int numberOfOptions = 3; // Number of options to generate
  int? specificIndex; // Index you want to match
  setSpecificIndex(int val) {
    specificIndex = val;
    notifyListeners();
  }

  bool loadingInit = true;

  Future<List<int>> generateUniAndOptionsForVerifyNewWallet(List data,
      [bool loading = true]) async {
    uniqueNumbers.clear();
    options.clear();
    specificIndex = null;
    loadingInit = loading;
    notifyListeners();
    uniqueNumbers = await generateUniqueRandomNumbers(3, 12);
    specificIndex = uniqueNumbers.first;
    options = await generateOptions(data.map((e) => e.toString()).toList(),
        specificIndex!, numberOfOptions);
    await future(1000);
    loadingInit = false;
    notifyListeners();
    return uniqueNumbers;
  }

  Future<List<int>> generateUniqueRandomNumbers(
      int count, int maxExclusive) async {
    if (count > maxExclusive) {
      throw ArgumentError('Count should be less than or equal to maxExclusive');
    }

    List<int> uniqueNumbers = [];
    Random random = Random();

    while (uniqueNumbers.length < count) {
      int randomNumber = random.nextInt(maxExclusive);
      if (!uniqueNumbers.contains(randomNumber)) {
        uniqueNumbers.add(randomNumber);
      }
    }
    infoLog('uniq numbers are $uniqueNumbers');
    return uniqueNumbers;
  }

  Future<List<String>> generateOptions(
      List<String> words, int specificIndex, int numberOfOptions) async {
    if (specificIndex >= words.length || numberOfOptions >= words.length) {
      throw ArgumentError('Invalid index or number of options');
    }

    List<String> options = [];
    Random random = Random();

    /*// Add the word at the specific index
    options.add(words[specificIndex]);

    while (options.length < numberOfOptions) {
      int randomIndex = random.nextInt(words.length);
      String randomWord = words[randomIndex];

      if (!options.contains(randomWord)) {
        options.add(randomWord);
      }
    }
*/
    options = uniqueNumbers.map((e) => words[e]).toList();
    // Shuffle the options so that the correct answer isn't always in the same position
    options.shuffle();
    options.shuffle();
    options.shuffle();

    infoLog('options are $options');
    return options;
  }

  //apis
  ButtonLoadingState creatingMnemonics = ButtonLoadingState.idle;
  String? errorText;
  Future<List<String>?> createNewWallet() async {
    Map map = {};
    try {
      if (isOnline) {
        creatingMnemonics = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        var (data, status, ce) = await ApiHandler.hitApi(tag,
            ApiConst.generateMnemonic, () => walletRepo.generateMnemonic());
        infoLog('data: $data, status: $status', tag);
        if (status && data != null) {
          try {
            creatingMnemonics = ButtonLoadingState.completed;
            errorText = 'success message';
            notifyListeners();
            return data['mnemonic'].split(' ').toList();
          } catch (e) {}
        } else {
          creatingMnemonics = ButtonLoadingState.failed;
          errorText = 'error message';
          notifyListeners();
        }
      } else {
        creatingMnemonics = ButtonLoadingState.failed;
        errorText = 'failed message';
        notifyListeners();
      }
    } catch (e) {
      // await Future.delayed(const Duration(seconds: 3));
      creatingMnemonics = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    // await Future.delayed(const Duration(seconds: 1));
    creatingMnemonics = ButtonLoadingState.idle;

    errorText = null;
    notifyListeners();
    return null;
  }

  ButtonLoadingState verifyingMnemonics = ButtonLoadingState.idle;
  String? verifyErrorText;

  Future<(Map<String, dynamic>, bool)?> verifyMnemonics(List<String> mnemonic,
      {bool imported = false, String? chain}) async {
    String? errorText;
    Map map = {};
    try {
      if (isOnline) {
        verifyingMnemonics = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        Map<String, dynamic> postData = {
          'mnemonic': mnemonic.join(' ').toString()
        };
        if (imported) {
          postData.addAll({"importWallet": true, "chain": chain});
        }
        warningLog('postData -> $postData', tag);
        var (data, status, ce) = await ApiHandler.hitApi(
            tag,
            ApiConst.generateMnemonic,
            () => walletRepo.verifyMnemonic(postData));
        infoLog('data: $data, status: $status', tag);
        infoLog('status: $status', tag);
        if (status && data != null) {
          try {
            await SpUtils().setMnemonic(mnemonic.join(' '));
            verifyingMnemonics = ButtonLoadingState.completed;
            verifyErrorText = errorText = 'success message';
            notifyListeners();
            return (data, status);
          } catch (e) {
            errorLog('verifyMnemonics $e', tag);
          }
        } else {
          verifyingMnemonics = ButtonLoadingState.failed;
          errorText = 'error message';
          notifyListeners();
        }
      } else {
        verifyingMnemonics = ButtonLoadingState.failed;
        errorText = 'failed message';
        notifyListeners();
      }
    } catch (e) {
      // await Future.delayed(const Duration(seconds: 3));
      verifyingMnemonics = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    // await Future.delayed(const Duration(seconds: 1));
    verifyingMnemonics = ButtonLoadingState.idle;
    errorText = null;
    verifyErrorText = errorText;
    notifyListeners();
    return null;
  }

  ButtonLoadingState loadingWallets = ButtonLoadingState.idle;
  List<Coin> wallets = [];
  List<RecentUsers> recentUsers = [];
  Future<void> selectCoin(BuildContext context,
      {bool loading = true, bool token = true}) async {
    warningLog('selectCoin called with token  -> $token', tag);
    String? errorText;
    try {
      loadingWallets =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(
          tag, ApiConst.selectWallet, () => walletRepo.selectWallet(token),
          cache: true);
      if (status) {
        try {
          if (data!['wallets'] != null) {
            wallets.clear();
            for (var e in data['wallets']) {
              if (!token) {
                if (e['parentWallet'] != e['contractAddress']) continue;
                wallets.add(Coin.fromJson(e));
              } else {
                wallets.add(Coin.fromJson(e));
              }
            }
          }
          // if (data['recentUsers'] != null) {
          //   recentUsers.clear();
          //   data['recentUsers'].forEach((e) {
          //     recentUsers.add(RecentUsers.fromJson(e));
          //   });
          // }
          loadingWallets = ButtonLoadingState.completed;
          notifyListeners();
        } catch (e) {
          loadingWallets = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('selectWallet $e', tag);
        }
      } else {
        loadingWallets = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      loadingWallets = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong! ->selectWallet';
      notifyListeners();
    }
    loadingWallets = ButtonLoadingState.idle;
    if (errorText != null) {
      Toasts.fToast(errorText);
    }
    notifyListeners();
  }

  ButtonLoadingState gettingBalance = ButtonLoadingState.idle;
  Future<Map<String, dynamic>?> getBalance(
      String chainName, String walletAddress,
      [String? contractAddress, bool loading = true]) async {
    String? errorText;
    try {
      gettingBalance =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      Map<String, dynamic> postData = {
        "chain": chainName,
        "address": walletAddress
      };
      // if (contractAddress == null) {
      postData.addAll({'contractAddress': contractAddress ?? chainName});
      // }
      var (data, status, ce) = await ApiHandler.hitApi(
          tag, ApiConst.getBalance, () => walletRepo.getBalance(postData),
          cache: false);
      if (status) {
        try {
          // await future(2000);
          gettingBalance = ButtonLoadingState.completed;
          notifyListeners();
          return data!['data'];
        } catch (e) {
          gettingBalance = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('selectWallet $e', tag);
        }
      } else {
        gettingBalance = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      gettingBalance = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong! ->selectWallet';
      notifyListeners();
    }
    gettingBalance = ButtonLoadingState.idle;
    if (errorText != null) {
      Toasts.fToast(errorText);
    }
    notifyListeners();
    return null;
  }

  //confirm transaction
  ButtonLoadingState loadingConfirmation = ButtonLoadingState.idle;
  String? confirmationText;

  Future<(Map<String, dynamic>, bool)?> confirmTransaction(
      Map<String, dynamic> transData) async {
    String? errorText;
    Map map = {};
    try {
      if (isOnline) {
        loadingConfirmation = ButtonLoadingState.loading;
        errorText = '';
        notifyListeners();
        var (data, status, ce) = await ApiHandler.hitApi(
            tag,
            ApiConst.confirmTransaction,
            () => walletRepo.confirmTransaction(transData));
        infoLog('data: $data, status: $status', tag);
        if (status && data != null) {
          try {
            loadingConfirmation = ButtonLoadingState.completed;
            verifyErrorText = errorText = 'success message';
            notifyListeners();
            return (data['data'] as Map<String, dynamic>, status);
          } catch (e) {}
        } else {
          loadingConfirmation = ButtonLoadingState.failed;
          errorText = 'error message';
          notifyListeners();
        }
      } else {
        loadingConfirmation = ButtonLoadingState.failed;
        errorText = 'failed message';
        notifyListeners();
      }
    } catch (e) {
      loadingConfirmation = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    loadingConfirmation = ButtonLoadingState.idle;
    confirmationText = errorText;
    if (confirmationText != null) {
      Toasts.fToast(confirmationText!);
    }
    notifyListeners();
    return null;
  }

  // init transaction

  ButtonLoadingState loadingInitTrans = ButtonLoadingState.idle;
  Future<Map<String, dynamic>?> initTransaction(
      BuildContext context, Map<String, dynamic> walletData,
      [bool loading = true]) async {
    String? errorText;
    try {
      loadingInitTrans =
          loading ? ButtonLoadingState.loading : ButtonLoadingState.idle;
      notifyListeners();
      var (data, status, ce) = await ApiHandler.hitApi(
          tag,
          ApiConst.initTransaction,
          () => walletRepo.initTransaction(walletData),
          cache: false);
      infoLog('data: $data');
      if (status) {
        try {
          loadingInitTrans = ButtonLoadingState.completed;
          notifyListeners();
          return data;
        } catch (e) {
          loadingInitTrans = ButtonLoadingState.failed;
          errorText = 'Some thing went wrong!';
          notifyListeners();
          errorLog('initTransaction $e', tag);
        }
      } else {
        loadingInitTrans = ButtonLoadingState.failed;
        errorText = data?['message'];
        notifyListeners();
      }
    } catch (e) {
      loadingInitTrans = ButtonLoadingState.failed;
      errorText = 'Some thing went wrong!';
      notifyListeners();
    }
    loadingInitTrans = ButtonLoadingState.idle;
    notifyListeners();
    if (errorText != null) {
      Toasts.fToast(errorText);
    }
    return null;
  }
}
