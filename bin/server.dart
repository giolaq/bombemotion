library multiplayer_example_force;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:force/force_serverside.dart';
import 'package:force/force_common.dart';

import 'dart:math';

part 'game.dart';

final Logger log = new Logger('ChatApp');

void main() {

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 8080 : int.parse(portEnv);
  var serveClient = portEnv == null ? true : false;

  const TIMEOUT = const Duration(seconds: 1);
  var number = 60 * 2;



  ForceServer fs = new ForceServer(host: "0.0.0.0", port: port, clientFiles: '../build/web/', clientServe: serveClient, startPage: "game.html");

  // Setup logger
  fs.setupConsoleLog();

  void handleTimeout() {
    number = number - 1;

    print("send a number to the clients $number");

    var data = {
      "count": "$number"
    };
    fs.send("updateTime", data);
  }


  startTimeout() {
    return new Timer(TIMEOUT, handleTimeout);
  }
  
 
  // Profile shizzle
  List<String> playerList = new List<String>();
  fs.onProfileChanged.listen((e) {
    String name = e.profileInfo['name'];
    if (e.type == ForceProfileType.New) {
      playerList.add(name);

      fs.send('entered', {
        'name': name
      });
    }
    if (e.type == ForceProfileType.Removed) {
      playerList.remove(name);

      fs.send('leaved', {
        'name': name
      });
    }
  });
  
  void assignBomb() {
     var rng = new Random();
     var numbersOfPlayers = playerList.length;
     number=rng.nextInt(numbersOfPlayers);
     print("Bomb to ${playerList.elementAt(number)}");
   }


  fs.on('list', (e, sendable) {
    sendable.sendTo(e.wsId, 'list', playerList);
  });



  fs.on('start', (e, sendable) {
    print("Start");
    startTimeout();
    assignBomb();
    fs.send('go', {});
  });
  

  fs.on('launch', (e, sendable) {
    print("Launch");
    assignBomb();
  });

  fs.start();
}
