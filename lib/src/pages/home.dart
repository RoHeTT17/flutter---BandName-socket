import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/src/services/socket_service.dart';
import 'package:band_names/src/models/band.dart';


class HomePage extends StatefulWidget {
 
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    //Se comentan por que ahora se cargaran las del backend
    // Band(id: '1', name:  'Pop', votes: 5),
    // Band(id: '2', name:  'Rock', votes: 5),
    // Band(id: '3', name:  'Clasica', votes: 5),
    // Band(id: '4', name:  'Electronica', votes: 5),
    // Band(id: '5', name:  'Banda', votes: 5),
  ];

@override
  void initState() {
    
    final socketServer = Provider.of<SocketService>(context,listen: false);
     //Escuchar evento del server

    // Se sustituye por _handleActiveBands
    // socketServer.getSocket.on('active-bands', (payload){
    //   //Dart lo interpreta como ub objeto dynamic, por lo que se debe mappear
    //   //Para esto se castea el payload como List

    //   this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    //   setState(() {
        
    //   });

    // });
    socketServer.getSocket.on('active-bands', _handleActiveBands);

    super.initState();
  }

_handleActiveBands( dynamic payload){

  //Dart lo interpreta como ub objeto dynamic, por lo que se debe mappear
  //Para esto se castea el payload como List

  this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

  setState(() { });

}

@override
  void dispose() {

    final socketServer = Provider.of<SocketService>(context,listen: false);

    //Dejar de escuchar un evento 
    socketServer.getSocket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketServer = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child:  (socketServer.getServerStatus == ServerStatus.Online)
                   //(socketServer.getServerStatus.name.contains('Online'))
                   ?       Icon(Icons.check_circle, color: Colors.blue[300],)
                   : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
     
      body: Column(
        children: [
          
                    (bands.isNotEmpty)
                    ? _showGraph(bands)
                    : const Text('No hay bandas', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),

                    Expanded(
                      //Se envuelve en un Expanded, para que tome todo el espacio disponible
                      //al ListView se le debe indicar cual tamaño debe tomar, al estar en un
                      //column no sabe cuanto espacio tomar.
                      child: ListView.builder(
                        itemCount: bands.length,
                        itemBuilder: (BuildContext context, int index) =>  _bandTile(band: bands[index]),
                      ),
                    ),
                  ],
      ),

      floatingActionButton: FloatingActionButton(
       elevation: 1, 
       onPressed:  addNewBand,
       child: const Icon(Icons.add),
      ),
   );
  }

  void addNewBand(){

   final textController = TextEditingController();

   if (Platform.isAndroid){

        showDialog(
          //Aquí se puede referenciar el context porque esta en un StatefulWidget,
          //lo cual vuelve context Global (dentro de esta clase)
          context: context, 
          builder: (BuildContext context){

            return AlertDialog(
              title: const Text('New band name:'),
              content:  TextField(
                                  controller: textController,
                                ),
              actions: [
                        MaterialButton(
                          elevation: 5,
                          textColor: Colors.blue,
                          onPressed: () => addBandToList(textController.text),
                          child: const Text('Add')
                        )
                      ],
            );
          }
      );
   }else{

      showCupertinoDialog(
        
        context: context, 
        builder: ( _ ) {

          return CupertinoAlertDialog(
            title: const Text('New band name:'),
            content: CupertinoTextField( controller: textController,),
            actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () => addBandToList(textController.text),
                          child: const Text('Add'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true, //con esto se pone rojo para el cancelar
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Dismiss'),
                        )                      
                      ],
          );
        }
      );
    
    }

  }

  void addBandToList(String name){


    final socketService = Provider.of<SocketService>(context,listen: false);
    
    if(name.length>1){
       //podemos agregar 
       //código de prueba cuando se estaba creando la app
       //  setState(() {
       //     bands.add(new Band(id: DateTime.now().toString(), name: name));
       //  }); 

       //emitir: add-band {name: name}

      socketService.getEmit('add-band',{'name': name});

    }

    Navigator.pop(context);
  }

}

class _bandTile extends StatelessWidget {

  final Band band;

  const _bandTile({ Key? key,required this.band,}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id), //es un identificador unico
      //Para indicar en que direccion se debe mover. Por default se meuve a varios lados
      direction: DismissDirection.startToEnd, 
      onDismissed: (DismissDirection direction){
            socketService.getEmit('delete-band',{'id':band.id});
      },

      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
         child: const Align(
          alignment: Alignment.centerLeft,  
          child: Text('Delete Band', style: TextStyle(color: Colors.white),)
          ), 
      ),
      child: ListTile(
        leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(band.name!.substring(0,2)),
                              ),
        title: Text(band.name!),
        trailing: Text('${band.votes!}', style: const TextStyle(fontSize: 28),),     
        onTap: (){
          socketService.getSocket.emit('vote-band',{'id': band.id});
        },                        
      ),
    );
  }
}

Widget _showGraph(List<Band> bands){

   Map<String, double> dataMap = {};//{
        //   "Flutter": 5,
        //   "React": 3,
        //   "Xamarin": 2,
        //   "Ionic": 2,
        // };

  bands.forEach((element) => {
      //print('name: ${element.name}'),
      //print('vote ${element.votes}')      
      dataMap.putIfAbsent(element.name!, () => element.votes!.toDouble())

  });

    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.pink[50]!,
      Colors.pink[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
    ];

  /*const List<Color> defaultColorList = [
    Color(0xFFff7675),
    Color(0xFF74b9ff),
    Color(0xFF55efc4),
    Color(0xFFffeaa7),
    Color(0xFFa29bfe),
    Color(0xFFfd79a8),
    Color(0xFFe17055),
    Color(0xFF00b894),
  ];*/

  return SizedBox(
    width: double.infinity,
    height: 150,
    child: PieChart(dataMap: dataMap)
           /* PieChart(
              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 32,
              //chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "HYBRID",
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                //legendShape: _BoxShape.circle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
              // gradientList: ---To add gradient colors---
              // emptyColorGradient: ---Empty Color gradient---
            )*/
    ) ;
}