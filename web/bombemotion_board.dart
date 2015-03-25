import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'package:polymer/polymer.dart';
import 'package:forcetictactoe/shared.dart';
import 'package:firebase/firebase.dart' show Firebase;


import 'package:stagexl/stagexl.dart' as StageXL;


/**
 * The Bombemotion Board component
 */
@CustomTag('bombemotion-board')
class BombemotionBoard extends PolymerElement with Client {
  @observable User user;

  @observable List<User> leaderBoard = toObservable([]);

  @observable List<User> topList = toObservable([]);

  @observable List<User> startChallengeUsers = toObservable([]);

  @observable String winnerTime;

  @observable String challengeTime = '';

  @observable String startChallengeStatus = '';

  @observable String startChallengeBtnLabel = 'Start';

  @observable String errorMessage = '';

  @observable bool challengeOngoing = false;
  
  Stopwatch _stopWatch = new Stopwatch();

  Timer _challengeTimer;

  CanvasElement canvas;

  BombemotionBoard.created() : super.created() {
    onConnect("anonymous");
  }


  Random random = new Random();
  StageXL.Stage stage;
  StageXL.RenderLoop renderLoop;

  @override
  void domReady() {
    var navicon = $['navicon'];
    var drawerPanel = $['drawerPanel'];

    navicon.onClick.listen((e) => drawerPanel.togglePanel());
  }

  void userChanged(User oldValue, User newValue) {
    playName = newValue.name;
    sendProfile();
    _connect();
    _connectFirebase();
  }


  void _connect() {

    canvas = this.shadowRoot.querySelector('#stage');
    stage = new StageXL.Stage(canvas, webGL: true, width: 800, height: 600);
    stage.scaleMode = StageXL.StageScaleMode.SHOW_ALL;
    stage.align = StageXL.StageAlign.NONE;

    
    renderLoop = new StageXL.RenderLoop();
    renderLoop.addStage(stage);

    stagexl();

  }

  void _connectFirebase() {
    var fb = new Firebase('${firebaseUrl}/toplist');
    print("Firebase");
    fb.onValue.listen((event) {
      List users = event.snapshot.val();
      if (users != null) topList = users.map((u) => new User.fromMap(u)).toList();
      leaderBoard = topList;
      for (User user in leaderBoard){
        print(user.name);
      }
    });
    
  }

  void showAbout() {
    async((_) => $['about_dialog'].toggle());
  }


  

  /// Returns the player info for the [side] ('Black' or 'White')
  String getPlayerInfo(String side) {
    // if (_chessBoard == null) {
    //  return '';
    // }
    var name = "prova"; //_chessBoard.header[side];
    if (name == null) {
      return '';
    }
    var rating = "180"; //_chessBoard.header[side + 'Elo'];
    if (rating != null) {
      return '${name} (${rating})';
    }
    return name;
  }

  void stagexl() {

    stage.juggler.clear();
    stage.removeChildren();
    StageXL.BitmapData.load("img/logo.png").then(startAnimation);
  }

  void drawBomb() {

    stage.juggler.clear();
    stage.removeChildren();

    StageXL.BitmapData.load("img/bomb.png").then(startAnimation);
  }

  void startAnimation(StageXL.BitmapData logoBitmapData) {

    var rect = stage.contentRectangle;
    var hue = random.nextDouble() * 2.0 - 1.0;
    var hueFilter = new StageXL.ColorMatrixFilter.adjust(hue: hue);

    var logoBitmap = new StageXL.Bitmap(logoBitmapData)
        ..pivotX = logoBitmapData.width ~/ 2
        ..pivotY = logoBitmapData.height ~/ 2
        ..x = rect.left + rect.width * 0.5//* random.nextDouble()
        ..y = rect.top + rect.height * 0.5//* random.nextDouble()
        ..rotation = 0.4 * random.nextDouble() - 0.2
        ..filters = [hueFilter];
       // ..scaleX = 1.0
      //  ..scaleY = 1.0;
       // ..addTo(stage);
    
    StageXL.Sprite logo = new StageXL.Sprite();
    logo.addChild(logoBitmap);
    logo.onMouseClick.listen(throwBomb);
    logo.onTouchTap.listen(throwBomb);
    logo.addTo(stage);
    
    stage.juggler.tween(logo, 1.0, StageXL.TransitionFunction.linear)
        ..animate.x.to(stage.contentRectangle.right);

    stage.juggler.tween(logo, 1.0, StageXL.TransitionFunction.linear)
        ..delay = 1.5
        ..animate.x.to(stage.contentRectangle.left)
        ..onComplete = () => () {logo.removeFromParent; 
        startAnimation(logoBitmapData);};

    //stage.juggler.delayCall(() => startAnimation(logoBitmapData), 0.1);
  }

  bombed() {
    count = 0;
    drawBomb();
  }

  saved() {
    hasBomb = false;
    stagexl();
  }

  die() {
    stage.mouseChildren = false;
    stage.juggler.clear();
    stage.removeChildren();

    var textField = new StageXL.TextField();
    textField.defaultTextFormat = new StageXL.TextFormat("Arial", 36, StageXL.Color.Black, align: StageXL.TextFormatAlign.CENTER);
    textField.width = 400;
    textField.x = stage.contentRectangle.center.x - 200;
    textField.y = stage.contentRectangle.center.y - 20;
    textField.text = "Game OVER!";
    textField.addTo(stage);
  }

  survive() {
    stage.mouseChildren = false;
    stage.juggler.clear();
    stage.removeChildren();

    var textField = new StageXL.TextField();
    textField.defaultTextFormat = new StageXL.TextFormat("Arial", 36, StageXL.Color.Black, align: StageXL.TextFormatAlign.CENTER);
    textField.width = 400;
    textField.x = stage.contentRectangle.center.x - 200;
    textField.y = stage.contentRectangle.center.y - 20;
    textField.text = "You Survived";
    textField.addTo(stage);
  }

  void throwBomb(StageXL.Event ev) {
    launch();
  }

}
