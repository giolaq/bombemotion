import 'dart:async';
import 'dart:html';

import 'package:force/force_browser.dart';
import 'package:stagexl/stagexl.dart';

import 'dart:convert' show HtmlEscape;

class Client {

  final DivElement log = new DivElement();
  int color = Color.Red;
  Stage stage;
  var uid = "";
  String opponent;
  List<List> playlist;

  DivElement statusElement = querySelector('#status');

  ForceClient forceClient;

  DivElement playListElement = querySelector("#nameslist");
  DivElement emptyList = querySelector("#emptyList");

  //name
  InputElement nameElement = querySelector("#name");

  //opponent_name
  SpanElement opponentElement = querySelector("#opponent_name");

  //screens
  DivElement enterScreen = querySelector("#enter_screen");
  DivElement opponentScreen = querySelector("#opponent_screen");
  DivElement gameScreen = querySelector("#game_screen");


  DivElement timeField = querySelector("#time");
  ButtonElement launchButton = querySelector("#launchButton");
  OutputElement _output = querySelector('#list');
  DivElement gameOverElement = querySelector('#gameover');

  String playName;
  HtmlEscape sanitizer = new HtmlEscape();

  Client() {
    print('start force client!');
    forceClient = new ForceClient();
    forceClient.connect();
    launchButton.hidden = true;

    nameElement.onChange.listen((e) {
      e.preventDefault();

      playName = nameElement.value;
      enterScreen.style.display = "none";
      opponentScreen.style.display = "block";

      var profileInfo = {
        'name': playName
      };
      forceClient.initProfileInfo(profileInfo);

      forceClient.send('list', {});

      e.stopPropagation();
    });

    nameElement.focus();

   

    launchButton.onClick.listen((e) {
         launchButton.hidden = true;
         forceClient.send('launch', {});
       });
    
    forceClient.onMessage.listen((e) {
      onMessage(e.request, e.json);
    });
    
    forceClient.onConnected.listen((e) {
      onConnected();
    });

    forceClient.onDisconnected.listen((e) {
      onDisconnected();
    });

    forceClient.on("list", (e, sender) {
      addPlayNames(e.json);
    });

    forceClient.on("go", (e, sender) {
     // goWithTheGame();
    });
    
    forceClient.on("bomb", (e, sender) {
         bombed();
       });

    forceClient.on("entered", (e, sender) {
      if (playName != e.json['name']) {
        addPlayName(e.json['name']);
      }
    });

    forceClient.on("leave", (e, sender) {
      var names = e.json;
      print('remove names : $names');

      for (var name in names) {
        removePlayName(name);
      }
    });

    forceClient.on("leaved", (e, sender) {
      removePlayName(e.json['name']);
    });

    
    forceClient.on("gameover", (e, sender) {
        gameOver();
      });


    forceClient.on("updateTime", (fme, sender) {
      timeField.innerHtml = "${fme.json["count"]}";
      if (int.parse('${fme.json["count"]}') > 10) {
        const TIMEOUT = const Duration(milliseconds: 500);
        var x = 1;
        new Timer.periodic(TIMEOUT, (Timer t) {
          var set = 1;
          if (x == 0 && set == 1) {
            document.body.style.backgroundColor = 'red';
            x = 1;
            set = 0;
          }
          if (x == 1 && set == 1) {
            document.body.style.backgroundColor = 'white';
            x = 0;
            set = 0;
          }
        });
      }
    });
  }

  void onConnected() {
    setStatus('');
    nameElement.disabled = false;

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
    link.className = "clickable";
    link.innerHtml = "$name";
    result.children.add(link);
    playListElement.children.add(result);

    link.onClick.listen((e) {
      print('opponent of your choice $name');

      this.uid = forceClient.generateId();
      var request = {
        'gameId': uid,
        'opponent': name
      };

      startGame(name);
      color = Color.Blue;

      forceClient.send("start", request);
    });
    emptyList.style.display = "none";
  }

  void startGame(String name) {
    opponent = name;
    opponentElement.innerHtml = name;

    opponentScreen.style.display = "none";
    gameScreen.style.display = "block";

    buildPlayField();
  }

  void buildPlayField() {
    print("build play field");
    var canvas = querySelector('#stage');
    this.stage = new Stage(canvas);
    var renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

   

  }
  
  void removePlayName(removedName) {
    Element removed;
    for (Element el in playListElement.children) {
      var link = el.children.first;
      if (link.innerHtml == removedName) {
        print("$removedName will be removed");
        removed = el;
      }
    }
    playListElement.children.remove(removed);
    if (playListElement.children.isEmpty) {
      emptyList.style.display = "block";
    }
  }
  
  void bombed() {
    launchButton.hidden = false;
  }
  
  void gameOver(){
    if ( launchButton.hidden == false ) {
      TextAreaElement textEl = new TextAreaElement();
      textEl.text = "GAME OVER";
      gameOverElement.children.add(textEl);
      launchButton.hidden = true;
    }
  }
}



void main() {
  var client = new Client();
}
