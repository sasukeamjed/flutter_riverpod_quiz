import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod_quiz/controllers/quiz/quiz_controller.dart';
import 'package:flutter_riverpod_quiz/controllers/quiz/quiz_state.dart';
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
        (ref) =>
        ref.watch(quizRepositoryProvider).getQuestions(
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
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
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
          data: (questions) => _buildBody(context, pageController, questions),
          loading: () =>
          const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) =>
              QuizError(
                  message:
                  error is Failure ? error.message : 'Something went wrong!'),
        ),
        bottomSheet: quizQuestions.maybeWhen(
          data: (questions) {
            final quizSatet = useProvider(quizControllerProvider.state);
            if (!quizSatet.answered) return const SizedBox.shrink();
            return CustomButton(
                title: pageController.page.toInt() + 1 < questions.length
                    ? 'Next Question'
                    : 'See Results', onTap: () {
              context.read(quizControllerProvider).nextQuestion(
                  questions, pageController.page.toInt());
              if (pageController.page.toInt() + 1 < questions.length) {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.linear)
              }
            });
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PageController pageController,
      List<Question> questions) {
    if (questions.isEmpty) return QuizError(message: "No Questions Found");

    final quizState = useProvider(quizControllerProvider.state);
    return quizState.status == QuizStatus.complete ? QuizResults(
        state: quizState, questions: questions)
        : QuizQuestions(
        pageController: pageController, state: quizState, questions: questions);
  }
}

class QuizResults extends StatelessWidget {
  final QuizState state;
  final List<Question> questions;

  const QuizResults({Key key, @required this.state, @required this.questions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${state.correct.length} / ${questions.length}', style: TextStyle(
          color: Colors.white, fontSize: 60.0, fontWeight: FontWeight.w600,),
          textAlign: TextAlign.center,),
        const SizedBox(height: 40.0,),
        CustomButton(title: 'New Quiz', onTap: (){
          context.refresh(quizRepositoryProvider);
          context.read(quizControllerProvider).reset();
        }),
      ],
    );
  }
}

class QuizQuestions extends StatelessWidget {
  final PageController pageController;
  final QuizState state;
  final List<Question> questions;

  const QuizQuestions({Key key, @required this.pageController, @required this.state, @required this.questions}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (BuildContext context, int index){
        final question = questions[index];
        return Column(
          mainAxisAlignment: ,
        );
      },
    );
  }
}



class QuizError extends StatelessWidget {
  final String message;

  const QuizError({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 20.0),
          CustomButton(
            title: 'Retry',
            onTap: () => context.refresh(quizRepositoryProvider),
          ),
        ],
      ),
    );
  }
}

final List<BoxShadow> boxShadow = const [
  BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 2),
    blurRadius: 4.0,
  )
];

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomButton({Key key, @required this.title, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        height: 50.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          boxShadow: boxShadow,
          borderRadius: BorderRadius.circular(20.0),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
