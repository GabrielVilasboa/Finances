import 'package:finance_app/screens/new_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/historic_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    runApp(const MyApp());
  } catch (e) {
    throw Exception("Erro ao carregar o arquivo .env: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HistoricScreen(title: 'Finances'),
      routes: <String, WidgetBuilder> {
        '/historicScreen': (BuildContext context) => const HistoricScreen(title: 'page A'),
        '/addTransaction': (BuildContext context) =>  NewTransactionScreen(title: 'Adicionar Saldo', isDebt: false,),
      },
    );
  }
}
