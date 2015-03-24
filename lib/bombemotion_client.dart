part of shared;



abstract class Client {

  var uid = "";
  List<List> playlist;


  ForceClient forceClient;

 
  String playName;
  bool hasBomb = false;
  num count = 0;

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
    if ( hasBomb ) {
      count = count + 1;
      print("launc $count");
      if ( count == 3 ) {
           forceClient.send('launch', {});
           count = 0;
           saved();
         }
    }
  
  }
  
  void gameOver(){
     print ("game over");
     if ( hasBomb ) {
       die();
     } else {
       survive();
     }
  }
}
