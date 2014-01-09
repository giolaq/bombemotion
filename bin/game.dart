library multiplayer_game_force;

import 'package:force/force_common.dart';
import 'package:force/force_serverside.dart';

class GameReceiver {
  
  Map<String, Game> games;
  
  GameReceiver() {
      games = new Map<String, Game>();
  }
  
  @Receiver("start") 
  void onGameStart(ForceMessageEvent vme, Sender sender) {
    String name = vme.json['opponent'];
    String uid = vme.json['gameId'];
    print("start game with $name");
    
    games[uid] = new Game();
    
    sender.sendToProfile('name', name, 'start_game', { 'uid' : uid, 'opponent' : vme.profile['name'] });
    
    List<String> opponents = new List<String>();
    opponents.add(name);
    opponents.add(vme.profile['name']);
    
    sender.send('leave', opponents);
  }
  
  @Receiver("play") 
  void onGamePlay(ForceMessageEvent vme, Sender sender) {
    String opponent = vme.json['opponent'];
    String uid = vme.json['gameId'];
    String name = vme.json['name'];
  
    
  }
  
}

class Game {
  List<List> playlist=[ ['-','-','-'], ['-','-','-'], ['-','-','-'] ]; 
}