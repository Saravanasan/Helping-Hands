import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helping_hand/src/foodDonor.dart';
import 'package:helping_hand/src/foodRecipient.dart';
import 'package:helping_hand/src/loginPage.dart';

final storage = new FlutterSecureStorage();

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  print('init');

  Widget _defaulthome = new LoginPage();

  String _result = await storage.read(key: 'role');
  print(_result);
  if (_result == 'Food Donor') {
    _defaulthome = new FoodDonorPage();
  }
  else if(_result == 'Food Recepient'){
    _defaulthome = new FoodRecepientPage();
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp(_defaulthome));
  });
}

class MyApp extends StatelessWidget {
  final _defaulthome ;

  MyApp(this._defaulthome);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'Helping Hand',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme:GoogleFonts.latoTextTheme(textTheme).copyWith(
          bodyText2: GoogleFonts.montserrat(textStyle: textTheme.bodyText2),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _defaulthome,
      routes: <String, WidgetBuilder>{
        '/foodDonor': (BuildContext context) => new FoodDonorPage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/foodRecipint': (BuildContext context) => new FoodRecepientPage()
      },
    );
  }
}
