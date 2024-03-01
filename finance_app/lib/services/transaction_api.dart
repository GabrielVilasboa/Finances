import 'package:finance_app/models/transaction.dart';
import 'package:finance_app/services/api_utils.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finance_app/services/connection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionApi{

  static const String _url = "http://10.0.2.2:8000/api/transactions/";

  static Future<List<Transaction>> getTransactions(int userId) async {
    String url =
        "http://10.0.2.2:8000/api/get-users-transaction/$userId/transaction";
    try {
      final basicAuth = dotenv.env['API_BASIC'];
      await checkInternetConnection();
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Basic $basicAuth'});
      if (response.statusCode == 200) {
        final transactionResponse = jsonDecode(response.body);
        List<Transaction> transactionsList = [];
        for (var transaction in transactionResponse) {
          transactionsList
              .add(Transaction.fromJson(transaction as Map<String, dynamic>));
        }
        return transactionsList;
      } else {
        throw Exception(
            "Erro ao carregar os dados da API: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro $e ao chamar a api");
    }
  }

  static Future<bool> postTransactions(Transaction newTransaction) async {
    try {
      Map<String, dynamic> bodyRequest = newTransaction.toMap();
      int status = await ApiUtils.postData(_url, bodyRequest);
      if (status == 201) {
        return true;
      }
      throw Exception("Api return: $status");
    } catch (e) {
      throw Exception("Aconteceu um erro: $e");
    }
  }

  static Future<bool> deleteTransaction(int transactionId) async {
    try{
      final transformedUrl = ("$_url$transactionId/");
      int status = await ApiUtils.deleteData(transformedUrl);
      if(status == 204) {
        return true;
      }else {
        throw Exception(status);
      }
    }catch(e) {
      throw Exception("aconteceu um erro: $e");
    }
  }
}
