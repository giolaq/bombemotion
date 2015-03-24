library multiplayer_example_force;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:force/force_serverside.dart';

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
  var number;

  Timer timer;

  ForceServer fs = new ForceServer(host: "0.0.0.0", port: port, clientFiles: '../build/web/', clientServe: true);


  // Setup logger
  fs.setupConsoleLog();

  void handleTimeout(Timer t) {
    number = number - 1;


    var data = {
      "count": "$number"
    };
    if (number == 0) {
      print("Game Over");
      timer.cancel();
      fs.send("gameover", data);
    } else {
      print("send a number to the clients $number");

      fs.send("updateTime", data);
    }
  }


  startTimeout() {
    if (timer != null) {
      timer.cancel();
    }
    number = 30 * 2;
    return new Timer.periodic(TIMEOUT, handleTimeout);
  }


  // Profile shizzle
  List<Player> playerList = new List<Player>();
  Player tabler;

  void assignBomb() {
    var rng = new Random();
    var numbersOfPlayers = playerList.length;
    if (numbersOfPlayers > 0) {
      var playerToBomb = rng.nextInt(numbersOfPlayers);
      print("Bomb to ${playerList.elementAt(playerToBomb).name}");
      fs.sendTo(playerList.elementAt(playerToBomb).wsId, 'bomb', {});
      fs.sendTo(tabler.wsId, 'bomb', {
        'name': playerList.elementAt(playerToBomb).name
      });
    }

  }

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
      playerList.removeWhere((Player p) => p.name == name);
      print('removed $name in $playerList');

      fs.send('leaved', {
        'name': name
      });
      print("Reassign bomb");
      if (playerList.length > 0) {
        assignBomb();
      }
    }
  });



  fs.on('list', (e, sendable) {
    //Hack to refactor
    List<String> plays = new List<String>();
    for (var player in playerList) {
      plays.add(player.name);
    }
    sendable.sendTo(e.wsId, 'list', plays);
  });

  fs.on('table', (e, sendable) {
    tabler = new Player('tabler', e.wsId);
  });



  fs.on('start', (e, sendable) {
    print("Start");
    timer = startTimeout();
    assignBomb();
    fs.send('go', {});
  });

  fs.on('stop', (e, sendable) {
    if ( timer != null ) {
      timer.cancel();
    }
    print("Stop");
    var data = {
        "count": "--"
      };
    fs.send("updateTime", data);

    fs.send('gameover', {});
  });

  fs.on('launch', (e, sendable) {
    print("Launch");
    assignBomb();
  });

  fs.start().then((_) {
    // Tell Force what the start page is!
    fs.server.static("/", "index.html");
  });
}
