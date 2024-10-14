import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Card model to represent each card's state
class CardModel {
  final String frontDesign; // Front design (could be an image or text)
  final String backDesign; // Back design
  bool isFaceUp; // Whether the card is face-up

  CardModel({
    required this.frontDesign,
    required this.backDesign,
    this.isFaceUp = false,
  });
}

// Game state to manage the cards and game logic
class GameState with ChangeNotifier {
  List<CardModel> cards = [];

  GameState() {
    // Initialize cards with front and back designs
    for (int i = 0; i < 8; i++) {
      cards.add(CardModel(frontDesign: 'Card $i', backDesign: 'Back $i'));
      cards.add(CardModel(frontDesign: 'Card $i', backDesign: 'Back $i'));
    }
    cards.shuffle(); // Shuffle the cards
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp) return; // Ignore if already face up

    cards[index].isFaceUp = true;
    notifyListeners();

    // Check for matches after a second card is flipped
    if (cards.where((card) => card.isFaceUp).length == 2) {
      Future.delayed(Duration(seconds: 1), () {
        // Logic to check if the two cards match
        final faceUpCards = cards.where((card) => card.isFaceUp).toList();
        if (faceUpCards[0].frontDesign != faceUpCards[1].frontDesign) {
          faceUpCards[0].isFaceUp = false;
          faceUpCards[1].isFaceUp = false;
        }
        notifyListeners();
      });
    }
  }
}

void main() {
  runApp(CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        title: 'Card Matching Game',
        home: GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Matching Game')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns (you can change this)
        ),
        itemBuilder: (context, index) {
          return CardWidget(index: index);
        },
        itemCount: 16, // 4x4 grid (16 cards)
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final int index;

  const CardWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final card = gameState.cards[index];

    return GestureDetector(
      onTap: () {
        gameState.flipCard(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: card.isFaceUp ? Colors.pink[200] : Colors.blue[400],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            card.isFaceUp
                ? card.frontDesign
                : '', // Show front design if face-up
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
