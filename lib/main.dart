import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/src/pages/status.dart';
import 'package:band_names/src/pages/home.dart';
import 'package:band_names/src/services/socket_service.dart';

void main(){
  return runApp(
                MultiProvider(
                              providers: [
                                          ChangeNotifierProvider<SocketService>(create: (BuildContext context) => new SocketService(),),
                                         ],
                              child: MyApp()
                             )
               );
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'status',
      routes: {
        'home'   :(context) => const HomePage(),
        'status' :(context) => const StatusPage(),
      },
    );
  }
}