import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkInfo {
  final InternetConnection connectionChecker;

  NetworkInfo(this.connectionChecker);

  Future<bool> get isConnected async =>
      await connectionChecker.hasInternetAccess;
}
