

abstract class BaseQuizRepository{
  Future<List<Question>> getQuestions(int numQuestions, int gategoryId, Difficulty difficulty);
}