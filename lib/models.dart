enum GameMode { endless, rush60, oneMistake }

enum HitGrade { match, perfect, miss }

String modeName(GameMode mode) {
  switch (mode) {
    case GameMode.endless:
      return 'Endless';
    case GameMode.rush60:
      return '60 Sec Rush';
    case GameMode.oneMistake:
      return 'One Mistake';
  }
}

String modeSubtitle(GameMode mode) {
  switch (mode) {
    case GameMode.endless:
      return 'Keep matching colors and chase your best score.';
    case GameMode.rush60:
      return 'Score as much as you can in 60 seconds.';
    case GameMode.oneMistake:
      return 'The first wrong match ends the run.';
  }
}
