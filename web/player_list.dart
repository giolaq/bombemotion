import 'package:polymer/polymer.dart';
export 'package:polymer/init.dart';
import 'package:template_binding/template_binding.dart';

import 'package:force/force_browser.dart';

class Person {
  final String h;
  final String v;
  Person({this.h, this.v});
}

@CustomTag('player-list')
class ListDemo extends PolymerElement {
  ForceClient forceClient;

  ListDemo.created() : super.created() {
    forceClient = new ForceClient();
    forceClient.connect();


    
    forceClient.on("entered", (e, sender) {
      addPlayName(e.json['name']);
    });
    
    forceClient.on("bomb", (e, sender) {
        bomb(e.json['name']);
      });
    
    forceClient.onConnected.listen((e) {
       onConnected();
     });

     forceClient.onDisconnected.listen((e) {
       onDisconnected();
     });
     
     forceClient.onMessage.listen((e) {
       onMessage(e.request, e.json);
     });
  }

  @observable String status = 'status';

  @observable int selected = 0;
  var lastMoved;
  int lastIndex = 0;

  ObservableList items = new ObservableList();

  ObservableList items2 = new ObservableList();

  void addPlayName(name) {
    this.items.insert(0, new Person(h: 'player', v: name));
    this.items2.insert(0, new Person(h: 'player', v: name));

  }
  
  void bomb(name) {
    Person bombedPerson = this.items.firstWhere( (Person p) => p.v == name);
    this.items.insert(0, bombedPerson);
  }

  void onConnected() {
    setStatus('connected');
    forceClient.send('table', {});

  }

  void onDisconnected() {
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
  }


  void onMessage(String request, dynamic json) {
    print("response on: '$request' with $json");
  }

  void setStatus(String status) {
    this.status = status;
  }


  reorder(e) {
    if ($['pages'].jsElement['transitioning']['length'] > 0) return;

    this.lastMoved = e.target;
    this.lastMoved.style.zIndex = '10005';
    var item = nodeBind(e.target).templateInstance.model.model;
    var items = this.selected > 0 ? this.items : this.items2;
    var i = this.selected > 0 ? this.items2.indexOf(item) : this.items.indexOf(item);
    if (i != 0) {
      items.insert(0, item);
      items.removeAt(i + 1);
    }

    this.lastIndex = i;
    this.selected = this.selected > 0 ? 0 : 1;
  }

  done() {
    var i = this.lastIndex;
    var items = this.selected > 0 ? this.items : this.items2;
    var item = items[i];
    items.insert(0, item);
    items.removeAt(i + 1);
    this.lastMoved.style.zIndex = null;
  }
}
