import 'dart:html';
import 'dart:math';

int wrongGuesses = 0;
const int GUESS_LIMIT = 5;
const String GREEK_WORD_LIST_FILE = "word_lists/greek.txt";
const String SPANISH_WORD_LIST_FILE = "word_lists/spanish.txt";
const String CAPITAL_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const List<String> HANG_IMAGES = const ["images/hang0.gif", "images/hang1.gif",
"images/hang2.gif", "images/hang3.gif",
"images/hang4.gif", "images/hang5.gif",
"images/hang6.gif"];


String WORD_LIST_FILE = "";
String lettersLeft, secretWord;
bool gameOver = true;

void main() {

  querySelector("#greek").onClick.listen((MouseEvent e) => fileSelect(GREEK_WORD_LIST_FILE));
  querySelector("#spanish").onClick.listen((MouseEvent e) => fileSelect(SPANISH_WORD_LIST_FILE));

  window.onKeyPress.listen((KeyboardEvent e) {
    String lastPressed = new String.fromCharCode(e.charCode);
    lastPressed = lastPressed.toUpperCase();
    playLetter(lastPressed);
  });
  querySelector("#changeCountry").onClick.listen((MouseEvent e) => reset());
  querySelector("#nextWord").onClick.listen((MouseEvent e) => fileSelect(WORD_LIST_FILE));
}

void reset() {
  querySelector(".flags").style.display = "inline-block";
  querySelector(".main").style.display = "none";
}

void fileSelect(String file) {
  WORD_LIST_FILE = file;
  querySelector(".flags").style.display = "none";
  querySelector(".main").style.display = "inline-block";
  gameOver = false;
  chooseSecretWord();
  clearBoard();
}

void playLetter(String letter) {

  if (lettersLeft.contains(letter) && !gameOver) {
    lettersLeft = lettersLeft.replaceFirst(new RegExp(letter), "");
    querySelector("#letter_list").text = lettersLeft;

    if (secretWord.contains(letter)) {
      String oldDisplay = querySelector("#secret").text;
      String newDisplay = "";

      for (var i = 0; i < secretWord.length; i++) {
        if (secretWord[i] == letter) {
          newDisplay += letter;
        } else {
          newDisplay += oldDisplay[i];
        }
      }

      querySelector("#secret").text = newDisplay;

      if (newDisplay == secretWord) {
        gameOver = true;
        querySelector("#letter_list").text = "YOU WIN!";
      }
    } else {
      wrongGuesses++;
      (querySelector("#hang_image") as ImageElement).src = HANG_IMAGES[wrongGuesses];
      if (wrongGuesses == GUESS_LIMIT) {
        gameOver = true;
        querySelector("#letter_list").text = "GAME OVER!";
        querySelector("#secret").text = secretWord;
      }
    }
  }


}

void clearBoard() {
  wrongGuesses = 0;
  (querySelector("#hang_image") as ImageElement).src = HANG_IMAGES[wrongGuesses];
  lettersLeft = CAPITAL_ALPHABET;
  querySelector("#letter_list").text = lettersLeft;
}

void chooseSecretWord() {
  HttpRequest request = new HttpRequest();
  request.open("GET", WORD_LIST_FILE, async: false);
  request.send();
  String wordList = request.responseText;
  List<String> words = wordList.split("\n");

  Random rnd = new Random();
  secretWord = words[rnd.nextInt(words.length)];
  secretWord = secretWord.toUpperCase();

  // hide what we display to the user - all underscores for letters
  querySelector("#secret").text = secretWord.replaceAll(new RegExp(r'[a-zA-Z]'), "_");
}