library multiplayer_example_force;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:force/force_serverside.dart';
import 'package:force/force_common.dart';

import 'dart:math';

part 'game.dart';

final Logger log = new Logger('ChatApp');

class Player {
  String name;
  String wsId;
  Player(this.name, this.wsId);
  }
void main() {

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 8080 : int.parse(portEnv);
  var serveClient = portEnv == null ? true : false;

  const TIMEOUT = const Duration(seconds: 1);
  var number = 60 * 2;

  Timer timer;

  ForceServer fs = new ForceServer(host: "0.0.0.0", port: port, clientFiles: '../build/web/', clientServe: true);

  // Setup logger
  fs.setupConsoleLog();

  void handleTimeout(Timer t) {
    number = number - 1;

    print("send a number to the clients $number");

    var data = {
      "count": "$number"
    };
    fs.send("updateTime", data);
  }


  startTimeout() {
    return new Timer.periodic(TIMEOUT, handleTimeout);
  }
  
 
  // Profile shizzle
  List<Player> playerList = new List<Player>();
  fs.onProfileChanged.listen((e) {
    String eid = e.wsId;
    String name = e.profileInfo['name'];
    if (e.type == ForceProfileType.New) {
      playerList.add(new Player(name, eid));

      fs.send('entered', {
        'name': name
      });
    }
    if (e.type == ForceProfileType.Removed) {
      playerList.removeWhere( (Player p ) => p.name == name);
      print('removed $name in $playerList' );
      
      fs.send('leaved', {
        'name': name
      });
    }
  });
  
  void assignBomb() {
     var rng = new Random();
     var numbersOfPlayers = playerList.length;
     var playerToBomb=rng.nextInt(numbersOfPlayers);
     print("Bomb to ${playerList.elementAt(playerToBomb).name}");
     fs.sendTo(playerList.elementAt(playerToBomb).wsId, 'bomb', {});

   }


  fs.on('list', (e, sendable) {
    //Hack to refactor
    List<String> plays = new List<String>();
    for ( var player in playerList) {
      plays.add(player.name);
    }
    sendable.sendTo(e.wsId, 'list', plays);
  });



  fs.on('start', (e, sendable) {
    print("Start");
    timer = startTimeout();
    assignBomb();
    fs.send('go', {});
  });
  

  fs.on('launch', (e, sendable) {
    print("Launch");
    assignBomb();
  });

  fs.start().then((_) {
   // Tell Force what the start page is!
     fs.server.static("/", "game.html");
   });
  }
