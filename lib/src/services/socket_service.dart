

//para dar o expandir la comunicación con el servidor en cualquier parte de la app
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus{
  Online,
  Offline,
  Connecting
}


class SocketService with ChangeNotifier{

  //Por defecto es Connecteing, porque la primera vez que se esta creando la instnacia
  //se va intentar hacer la conexión y aun no se sabe si esta offline u online
  ServerStatus _serverStatus = ServerStatus.Connecting;
  
  late IO.Socket _socket;

  SocketService(){
    //print('Iniciando config');
      _initConfig();
  }

 ServerStatus get getServerStatus => _serverStatus;

 IO.Socket get getSocket => this._socket;

 Function get getEmit => this._socket.emit;

 void _initConfig(){

   //Para local
   //final String urlSocket = 'http://172.16.2.25:3000/';
   
   //Heroku
   final String urlSocket = 'https://flutter-socket-server-curso3.herokuapp.com';

   // print('Iniciando Socket');

   // Dart client

    //IO.Socket socket = 
    //IO.io('http://localhost:3000/',{
    //Se volvio privado para controlar como se exponen a las demas pantallas (clase 31)
    //    
    _socket = IO.io(urlSocket,{ //localhost:3000
      'transports' : ['websocket'],//Como será la comunicación
      //Para conectarnos de manera automatica true. Si fuera false y nos quisieramos conectar en 
      //un determinado momento se usuario socket.connect()
      'autoConnect': true
    });
    
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      //socket.emit('msg', 'test');
    });

    //socket.on('event', (data) => print(data));
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    //socket.on('fromServer', (_) => print(_));

    //Agregar un nuevo metodo  para escuchar mensajes del servidor
    //Se aconseja no poner el tipado a la data que se esta recibiendo (payload)
    // socket.on('nuevo-msj', (payload) => {
    //   print('nuevo-msj:'),
    //   print('nombre: '+payload['nombre']),
    //   print('msj: '+payload['msj']),
    //   print(payload.containsKey('msj2') ? payload['msj2'] : 'no hay msj2')
    // });

  }
}