import 'dart:html';

import 'package:force/force_browser.dart';

class Table {

  final String tablename = "table";
  final DivElement log = new DivElement();
  var uid = "";

  DivElement statusElement = querySelector('#status');

  ForceClient forceClient;

  Table() {
    print('start force client!');
    forceClient = new ForceClient();
    forceClient.connect();

    var profileInfo = {
      'name': tablename
    };
    forceClient.initProfileInfo(profileInfo);

    forceClient.onMessage.listen((e) {
      onMessage(e.request, e.json);
    });

    forceClient.onConnected.listen((e) {
      onConnected();
    });

    forceClient.onDisconnected.listen((e) {
      onDisconnected();
    });


  }

  void onConnected() {
    setStatus('');
  }

  void onDisconnected() {
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
  }

  void setStatus(String status) {
    statusElement.innerHtml = status;
  }


  void onMessage(String request, dynamic json) {
    print("response on: '$request' with $json");
  }


}



void main() {
  var table = new Table();
}
