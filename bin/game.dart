library multiplayer_game_force;

import 'package:force/force_common.dart';
import 'package:force/force_serverside.dart';

class GameReceiver {
  
  Map<String, Game> games;
  
  GameReceiver() {
    Map<String, Game> games = new Map<String, Game>();
  }
  
  @Receiver("start") 
  void onGameStart(ForceMessageEvent vme, Sender sender) {
    String name = vme.json['opponent'];
    
    print("start game with $name");
  }
  
  @Receiver("play") 
  void onGamePlay(ForceMessageEvent vme, Sender sender) {
    
  }
  
}

class Game {
  List<List> playlist=[ ['-','-','-'], ['-','-','-'], ['-','-','-'] ]; 
}