import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/src/services/socket_service.dart';


class StatusPage extends StatelessWidget {
 
  const StatusPage({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado servidor: ${socketService.getServerStatus}')
          ]
        ),
     ),

     floatingActionButton: FloatingActionButton(
      onPressed: (){
        //El cliente manda un mensaje al servidor
          socketService.getSocket.emit('emitir-mensaje',{
            'nombre': 'Flutter', 
            'msj':'Hola desde Flutter'
          });
      },
      child: Icon(Icons.message_outlined),
    ),
   );
  }
}