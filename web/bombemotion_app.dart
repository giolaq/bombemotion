
import 'package:polymer/polymer.dart';
import 'package:forcetictactoe/shared.dart';

/**
 * The Bombemotion App component
 */
@CustomTag('bombemotion-app')
class BombemotionApp extends PolymerElement {
  @published User user;
  /// [true] if min-width is 900px
  @observable bool wide = true;
  @observable String selected = 'login';

  BombemotionApp.created() : super.created();

  void selectedChanged(String oldValue, String newValue) {
    if (selected == 'board') {
      print("board selected");
      async((_) => $['board'].resize());
    }
  }

}
