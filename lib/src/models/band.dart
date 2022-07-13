
class Band{

  String  id; //Este id lo propociona el Backend
  String? name;
  int? votes;

  Band({required this.id, this.name, this.votes = 0});

  //Adicional mente, cuando estemos conecto la app con el Bakend, el Backend va responder con un mapa, 
  //no directamente un string, porque al conectar con Sokets, estos responden con un mapa.

  factory Band.fromMap(Map<String, dynamic> obj){

      //se utiliza para recibir en el constructor un Map y con ello regresa una nueva instancia.
      return Band(id: obj['id'], name: obj['name'], votes: obj['votes']);

  }


}