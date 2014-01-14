import 'package:stagexl/stagexl.dart';
import 'dart:async';

class BlockPaint extends DisplayObjectContainer {
  int color;
  bool alreadyDrawn = false;
  
  StreamController<MouseEvent> _controller;
  
  BlockPaint(this.color) {
    this.onMouseClick.listen(_onMouseClick);
    
    _controller = new StreamController<MouseEvent>();
    
    print("this is a new block");
    addChild(_inner_draw(Color.BlanchedAlmond));
  }
  
  void own() {
    draw(this.color);
  }
  
  void draw(int color) {
    if (!alreadyDrawn) {
      var boxBitmap = _inner_draw(color);
      addChild(boxBitmap);
      alreadyDrawn = true;
    }
  }
  
  Bitmap _inner_draw(int color) {
    var box = new BitmapData(90, 90, false, color);
    var boxBitmap = new Bitmap(box);
    boxBitmap.x = 5;
    boxBitmap.y = 5;
    return boxBitmap;
  }
  
  void _onMouseClick(e) {
    if (!alreadyDrawn) {
      _controller.add(e);
    }
    own();
  }
  
  Stream listen() => _controller.stream;
}