extension Utils on int {
  String toTimeString() {
    String seconds = (this ~/ 1000 % 60).toString();
    String minutes = (this ~/ 1000 ~/ 60 % 60).toString();
    String hours = (this ~/ 1000 ~/ 60 ~/ 60).toString();
    if (seconds.length < 2) seconds = '0$seconds';
    if (minutes.length < 2) minutes = '0$minutes';
    if (hours.length < 2) hours = '0$hours';
    return '$hours:$minutes:$seconds';
  }
}
