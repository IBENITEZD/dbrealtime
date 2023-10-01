import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../data/position.dart';

class PositionController extends GetxController {
  // Todas las personas de la base de datos
  final _positions = <Position>[].obs;
  final String dbName = "geos";

  // Configuracion de la db
  final db = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent?> newData;
  late StreamSubscription<DatabaseEvent?> updateData;

  // Getter
  List<Position> get positions => _positions;

  // Metodo para iniciar los listeners
  start() {
    positions.clear();
    newData = db.child(dbName).onChildAdded.listen(_onAddData);
    updateData = db.child(dbName).onChildChanged.listen(_onUpdateData);
  }

  // Metodo para detener los listeners
  stop() {
    newData.cancel();
    updateData.cancel();
  }

  // Metodo que escucha los nuevos registros
  _onAddData(DatabaseEvent event) {
    logInfo('Data was Add...');
    final json = event.snapshot.value as Map<dynamic, dynamic>;
    _positions.add(Position.fromJson(event.snapshot, json));
  }

    // Metodo que escucha las actualizaciones de registros
  _onUpdateData(DatabaseEvent event) {
    logInfo('Data was Updated...');
    var oldData = _positions.singleWhere((element) {
      return element.key == event.snapshot.key;
    });

    final json = event.snapshot.value as Map<dynamic, dynamic>;
    _positions[_positions.indexOf(oldData)] =
        Position.fromJson(event.snapshot, json);
  }

  // Metodo para agregar 
  Future<void> addPosition(Position position) async {
    logInfo('New Position...');
    try {
      db.child(dbName).push().set(position.toJson());
    } catch (e) {
      logError('Error Add: $e');
      return Future.error(e);
    }
  }

  // Metodo para actualizar la posicion
  Future<void> updatePosition(Position position) async {
    logInfo('Update Position... $position.key');
    try {
      db.child(dbName).child(position.key!).set(position.toJson());
    } catch (e) {
      logError('Error Update: $e');
      return Future.error(e);
    }
  }

}
