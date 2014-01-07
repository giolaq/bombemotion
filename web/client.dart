import 'dart:async';
import 'dart:html';

import 'package:force/force_browser.dart';

class Client {
  
  final DivElement log = new DivElement();
  DivElement statusElement = querySelector('#status');
 
  ForceClient forceClient;
 
  DivElement playListElement = querySelector("#nameslist");
  
  //name
  InputElement nameElement = querySelector("#name");
  
  //2 parts
  DivElement enterScreen = querySelector("#enter_screen");
  DivElement opponentScreen = querySelector("#opponent_screen");
  
  String playName; 
  
  Client() {
    print('start force client!');
    forceClient = new ForceClient();
    forceClient.connect();
    
    nameElement.onChange.listen((e) {
      e.preventDefault();
      
      playName = nameElement.value;
      enterScreen.style.display = "none";
      opponentScreen.style.display = "block";
      
      var profileInfo = { 'name' : playName};
      forceClient.initProfileInfo(profileInfo);
      
      forceClient.send('list', {});
      
      e.stopPropagation();
    });
    
    nameElement.focus();
    
    forceClient.onConnecting.listen((e) {
      print("connection changed $e");
      if (e.type=="connected") {
        onConnected();
      } else if (e.type=="disconnected") {
        onDisconnected();
      }
    });
    
    forceClient.on("list", (e, sender) {
      addPlayNames(e.json);
    });
    
    forceClient.on("entered", (e, sender) {
      if (playName!=e.json['name']) {
        addPlayName(e.json['name']);
      }
    });
    
    forceClient.on("leaved", (e, sender) {
      removePlayName(e.json['name']);
    });
  }

  void onConnected() {
    setStatus('');
    nameElement.disabled = false;
    
    forceClient.onMessage.listen((e) {
      onMessage(e.request, e.json);
    });
  }

  void onDisconnected() {
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
    nameElement.disabled = true;
  }

  void setStatus(String status) {
    statusElement.innerHtml = status;
  }


  void onMessage(String request, dynamic json) {
     print("response on: '$request' with $json");
  }
  
  void addPlayNames(playnames) { 
    print("$playnames");
    playListElement.children.clear();
    for (var name in playnames) {
      if (name != playName) {
        addPlayName(name);
      }
    }
  }
  
  void addPlayName(name) {
    var result = new DivElement();
    var link = new AnchorElement();
    link.innerHtml = "$name";
    result.children.add(link);
    playListElement.children.add(result);
    
    link.onClick.listen((e) {
      print('opponent of your choice $name');
      
      var uid = forceClient.generateId();
      var request = {
                     'gameId': uid,
                     'opponent': name
      };
      
      forceClient.send("start", request );
    });
  }
  
  void removePlayName(removedName) {
    print("$removedName will be removed");
    Element removed;
    for (Element el in playListElement.children) {
      if (el.innerHtml == removedName) {
        removed = el;
      }
    }
    playListElement.children.remove(removed);
  }
}

void main() {
  var client = new Client();
}
