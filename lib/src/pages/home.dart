import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/src/models/band.dart';


class HomePage extends StatefulWidget {
 
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name:  'Pop', votes: 5),
    Band(id: '2', name:  'Rock', votes: 5),
    Band(id: '3', name:  'Clasica', votes: 5),
    Band(id: '4', name:  'Electronica', votes: 5),
    Band(id: '5', name:  'Banda', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
     
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) =>  _bandTile(band: bands[index]),
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
    
    if(name.length>1){
       //podemos agregar 
       setState(() {
          bands.add(new Band(id: DateTime.now().toString(), name: name));
       }); 
    }
    Navigator.pop(context);
  }

}

class _bandTile extends StatelessWidget {

  final Band band;

  const _bandTile({ Key? key,required this.band,}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: Key(band.id), //es un identificador unico
      //Para indicar en que direccion se debe mover. Por default se meuve a varios lados
      direction: DismissDirection.startToEnd, 
      onDismissed: (DismissDirection direction){
            //TODO: llamar el borrado en el server
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
          print(band.name!);
        },                        
      ),
    );
  }
}