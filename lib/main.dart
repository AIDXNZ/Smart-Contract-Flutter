import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_web3_provider/flutter_web3_provider.dart';

main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String tokenBalance = '0';

  String selectedAddress;

  String address = '0xB1Dd956C0Acf811b7a3CAAb09697849bbd0D4393';

  loadBalance() {
    var addr =
        EthereumAddress.fromHex('0xB1Dd956C0Acf811b7a3CAAb09697849bbd0D4393');
    var apiUrl =
        "https://mainnet.infura.io/v3/b63606f0825343fd85b553d6e471a53b";
    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);

    ethClient
        .getBalance(addr)
        .then((balance) => print(balance.getValueInUnit(EtherUnit.ether)));
  }

  callContract() async {
    var addr =
        EthereumAddress.fromHex('0xB1Dd956C0Acf811b7a3CAAb09697849bbd0D4393');
    var contractAddr = '0xBcca60bB61934080951369a648Fb03DF4F96263C';
    var apiUrl =
        "https://mainnet.infura.io/v3/b63606f0825343fd85b553d6e471a53b";
    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);
    final abiCode = await rootBundle.loadString("assets/abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, 'USDC'),
        EthereumAddress.fromHex(contractAddr));

    final balanceFunction = contract.function('balanceOf');
    final decimalFunction = contract.function('decimals');

    final decimal = await ethClient
        .call(contract: contract, function: decimalFunction, params: []);
    print("Decimal place ${decimal.first}");

    final balance = await ethClient
        .call(contract: contract, function: balanceFunction, params: [addr]);
    if (balance.isEmpty) {
      print("0.0 USDC");
    } else if (balance.isNotEmpty) {
      setState(() {
        double bal =
            double.tryParse(balance.first.toString()) / 1000000;
        tokenBalance = bal.toString();
      });
      print('We have ${balance.first} USDC');
    }
  }

  checkProvider() async {
    var accounts = await promiseToFuture(
        ethereum.request(RequestParams(method: 'eth_requestAccounts')));
    if (accounts != null) {
      print(accounts);
    } else {
      print('No Accounts');
    }
  }

  loadDefault() async {
    var box = await Hive.openBox('myBox');
    box.put('darkMode', false);
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    loadDefault();
    callContract();
    if (ethereum != null) {
      setState(() {
        address = ethereum.selectedAddress;
      });
      print(ethereum.selectedAddress);
    } else {
      print('No Address');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return ValueListenableBuilder(
      valueListenable: Hive.box('myBox').listenable(),
      builder: (context, box, widget) {
        return Scaffold(
          backgroundColor: box.get('darkMode') ? Colors.black : Colors.white,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 100,
          backgroundColor: box.get('darkMode') ? Colors.black : Colors.white,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Row(
            children: [
              CircleAvatar(child: Image.asset('icon.jpg'),
              radius: 60,
              ),
              Text('Saturn Finance', style: TextStyle(
                color: box.get('darkMode') ? Colors.white : Colors.black,
              ),)
            ],
          ),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(children: [
                Container(
                  child: Container(
                    height: 600,
                    width: 600,
                    decoration: BoxDecoration(
                      color: Color(0xFF5610D7),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(spreadRadius: 1,blurRadius: 200, color: Color(0xFF5610D7)),
                      ]
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(child: Image.asset('icon-usdc-1.jpeg'),radius: 60,),
                          Text('USDC', style: TextStyle(
                            color: Colors.white,
                            fontSize: 60
                          ),),
                          
                          Text(
                            '$tokenBalance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 68,
                            ),
                          ),
                          SizedBox(height: 200,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 83,
                                width: 225,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                
                                ),
                                child: Center(
                                  child: Text('Deposit', style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700
                                  ),),
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                height: 83,
                                width: 225,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                child: Center(
                                  child: Text('Withdraw', style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700
                                  ),),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            loadBalance();
            callContract();
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
      }
    );
  }
}
