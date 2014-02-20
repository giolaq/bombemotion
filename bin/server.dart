library multiplayer_example_force;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:force/force_serverside.dart';
import 'package:force/force_common.dart';

part 'game.dart';

final Logger log = new Logger('ChatApp');

void main() {
  // Set up logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 8080 : int.parse(portEnv);
  
  ForceServer fs = new ForceServer(host: "0.0.0.0", port: port, startPage: "game.html" );
  
  // Profile shizzle
  List<String> playerList = new List<String>();
  fs.onProfileChanged.listen((e) {
    String name = e.profileInfo['name'];
    if (e.type == ForceProfileType.New) {
      playerList.add(name);
      
      fs.send('entered', { 'name' : name });
    }
    if (e.type == ForceProfileType.Removed) {
      playerList.remove(name);
      
      fs.send('leaved', { 'name' : name });
    }
  });
  
  fs.on('list', (e, sendable) { 
    sendable.sendTo(e.wsId, 'list', playerList);
  });
  
  fs.start();
}
