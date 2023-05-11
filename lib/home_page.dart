import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake_game/blank_pikel.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

// ignore: camel_case_types, constant_identifier_names
enum snake_direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  int rowSize = 20;
  int totalNoOfSquares = 400;
  int currentScore = 0;
  bool gameHasStarted = false;

  List<int> snakePos = [0, 1, 2];
  var currentDirection = snake_direction.RIGHT;
  int foodPos = 192;
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //snake moving
        moveSnake();
        //game over
        if (gameOver()) {
          timer.cancel();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Game Over'),
                  content: Column(
                    children: [Text('Your score is  $currentScore ')],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);

                        newGame();
                      },
                      color: Colors.pink,
                      child: const Text('Again Start'),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {}

  void newGame() {
    setState(() {
      snakePos = [0, 1, 2];
      currentDirection = snake_direction.RIGHT;
      foodPos = 192;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNoOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_direction.RIGHT:
        {
          //add a new head
          if (snakePos.last % rowSize == 19) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snake_direction.LEFT:
        {
          //add a new head
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_direction.UP:
        {
          //add a new head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNoOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_direction.DOWN:
        {
          //add a new head
          if (snakePos.last + rowSize > totalNoOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNoOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // remove the tail
      snakePos.removeAt(0);
    }
  }

  bool gameOver() {
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //high score
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Current Score',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                currentScore.toString(),
                style: const TextStyle(fontSize: 30),
              )
            ],
          )),
          //game grid
          Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: ((details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_direction.UP) {
                    currentDirection = snake_direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_direction.DOWN) {
                    currentDirection = snake_direction.UP;
                  }
                }),
                onHorizontalDragUpdate: ((details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_direction.LEFT) {
                    currentDirection = snake_direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_direction.RIGHT) {
                    currentDirection = snake_direction.LEFT;
                  }
                }),
                child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalNoOfSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              )),
          //play button
          Expanded(
              child: Center(
            child: MaterialButton(
              color: gameHasStarted ? Colors.grey : Colors.pink,
              onPressed: gameHasStarted ? () {} : startGame,
              child: const Text('Play'),
            ),
          )),
        ],
      ),
    );
  }
}
