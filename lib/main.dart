import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod_quiz/enums/difficulty.dart';
import 'package:flutter_riverpod_quiz/models/failure.dart';
import 'package:flutter_riverpod_quiz/models/question_model.dart';
import 'package:flutter_riverpod_quiz/repositories/quiz/quiz_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Riverpod Quiz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        home: QuizScreen(),
      ),
    );
  }
}

final quizQuestionProvider = FutureProvider.autoDispose<List<Question>>(
    (ref) => ref.watch(quizRepositoryProvider).getQuestions(
          numQuestions: 5,
          categoryId: Random().nextInt(24) + 9,
          difficulty: Difficulty.any,
        ));

class QuizScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final quizQuestions = useProvider(quizQuestionProvider);
    final pageController = usePageController();
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4418E), Color(0xFF0652C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: quizQuestions.when(
          data: (questions)=> _buildBody(context, pageController, questions),
          loading: ()=> const Center(child: CircularProgressIndicator(),),
          error:  (error, _)=> QuizError(message: error is Failure ? error.message : 'Something went wrong!'),
        ),
      ),
    );
  }
}

class QuizError extends StatelessWidget{
  final String message;

  const QuizError({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

        ],
      ),
    );
  }
}
