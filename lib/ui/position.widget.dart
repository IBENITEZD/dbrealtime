import 'package:dbrealtime/domain/geo.controller.dart';
import 'package:dbrealtime/domain/position.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/position.dart';

class PeopleWidget extends StatefulWidget {
  const PeopleWidget({Key? key}) : super(key: key);

  @override
  State<PeopleWidget> createState() => _PeopleWidgetState();
}

class _PeopleWidgetState extends State<PeopleWidget> {
  // Controladores Get
  PositionController plpCtrl = Get.find();
  GeoController geoCtrl = Get.find();
  // Controladores Widgets
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late String lat = '0';
  late String long = '0';

  // Metodo para iniciar la instancia de los listeners
  @override
  void initState() {
    super.initState();
    plpCtrl.start();    
    miFuncion();
  }

  // Metodo para detener la instancia de los listeners
  @override
  void dispose() {
    plpCtrl.stop();
    super.dispose();
  }

  // Widget encargado de mostrar los mensajes que se encuentren
  // registrados en la base de datos
  Widget _messageCard(Position position, int index) {
    return Card(
      margin: const EdgeInsets.only(left: 50, top: 10, bottom: 10, right: 10),
      color: Colors.blue[100],
      child: ListTile(
        title: Text(
          position.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("${position.latitude}, ${position.longitude}"),
        onTap: () async {
          String url = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            //throw 'Could not launch $url';
          }
        },
      ),
    );
  }

  // Widget encargado de mostrar el listado de mensajes en la}
  // base de datos
  Widget _messageList() {
    return GetX<PositionController>(
      builder: ((controller) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
        return ListView.builder(
          itemCount: plpCtrl.positions.length,
          controller: _scrollCtrl,
          itemBuilder: ((context, index) {
            var msg = plpCtrl.positions[index];
            return _messageCard(msg, index);
          }),
        );
      }),
    );
  }

  // Widget para el input de texto
  Widget _messageInput() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Nombre",
        ),
        controller: _msgCtrl,
        onSubmitted: (value) async {
          await _add();
          _msgCtrl.clear();
        },
      ),
    );
  }

  // Hacer scroll de los mensajes nuevos
  _scrollToEnd() async {
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _openSettings() async {
    var status = await geoCtrl.getStatusGpsPermission();
    if (status.isPermanentlyDenied || status.isDenied) {
      openAppSettings();
    }
  }

  void _getPosition() async {
    try {
      var status = await geoCtrl.getStatusGpsPermission();
      if (!status.isGranted) {
        status = await geoCtrl.requestGpsPermission();
      }
      if (status.isGranted) {
        var pst = await geoCtrl.getCurrentPosition();
        lat = pst.latitude.toString();
        long = pst.longitude.toString();
      } else {
        lat = "0";
        long = "0";
      }
    } catch (e) {
      lat = "0";
      long = "0";
    }
  }

  // Metodo para enviar mensajes
  Future<void> _add() async {
    _getPosition();
    await plpCtrl.addPosition(Position(_msgCtrl.text, lat, long));
  }


 void miFuncion() {
    // Coloca aquí el código que deseas ejecutar al iniciar el StatefulWidget
    //print('El StatefulWidget se ha iniciado.');
    _msgCtrl.text = 'Posicion inicial';
    _add();
    _msgCtrl.text = '';
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _messageList(),
        ),
        _messageInput(),
      ],
    );
  }
}
