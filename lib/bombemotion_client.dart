part of shared;



abstract class Client {

  var uid = "";
  List<List> playlist;


  ForceClient forceClient;

 
  String playName;
  bool hasBomb = false;

  void onConnect(String name) {
    playName = name;
    print('start force client!');
    forceClient = new ForceClient();
    forceClient.connect();

  
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
      //addPlayNames(e.json);
    });

    forceClient.on("go", (e, sender) {
     // goWithTheGame();
    });
    
    forceClient.on("bomb", (e, sender) {
         hasBomb = true;
         bombed();
       });

    forceClient.on("entered", (e, sender) {
      if (playName != e.json['name']) {
        //addPlayName(e.json['name']);
      }
    });

    forceClient.on("leave", (e, sender) {
      var names = e.json;
      print('remove names : $names');

      for (var name in names) {
       // removePlayName(name);
      }
    });

    forceClient.on("leaved", (e, sender) {
      //removePlayName(e.json['name']);
    });

    forceClient.on("start_game", (e, sender) {
      //startGame(e.json['opponent']);
      this.uid = e.json['gameId'];
    });

    forceClient.on("gameover", (e, sender) {
        gameOver();
      });


    forceClient.on("updateTime", (fme, sender) {
    /*  timeField.innerHtml = "${fme.json["count"]}";
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
      }*/
    });
  }

  void onConnected() {
    setStatus('');

  }

  void onDisconnected() {
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
  }

  void setStatus(String status) {
    //statusElement.innerHtml = status;
  }


  void onMessage(String request, dynamic json) {
    print("response on: '$request' with $json");
  }

  void addPlayNames(playnames) {
    print("$playnames");
    //playListElement.children.clear();
    for (var name in playnames) {
      if (name != playName) {
      }
    }
  }

  void sendProfile() {
    var profileInfo = {
           'name': playName
         };
         forceClient.initProfileInfo(profileInfo);
  }
  
  void bombed();
  
  void saved();
  
  void die();
  
  void survive();
  
  void launch() {
    forceClient.send('launch', {});
  }
  
  void gameOver(){
     if ( hasBomb ) {
       die();
     } else {
       survive();
     }
  }
}
