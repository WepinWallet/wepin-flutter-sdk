class WepinUtils {
  int getTimeNowToInt() {
    DateTime now = DateTime.now();
    int time = now.millisecondsSinceEpoch;
    return time;
  }
}
