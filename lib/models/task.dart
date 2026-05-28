class Task {
  final int id;
  final String title;
  final String category;
  final String difficulty;
  final String scenario;
  final List<String> questions;
  final String answer;

  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.scenario,
    required this.questions,
    required this.answer,
  });
}

const List<String> kCategories = [
  'Все задачи',
  'Подсудность',
  'Основания ПС',
  'Сроки (не под стражей)',
  'Сроки (под стражей)',
  'Мировой судья',
  'Поиск ошибок',
  'Составление постановления',
  'Комплексные задачи',
];

const Map<String, String> kDifficultyLabels = {
  'easy': 'Лёгкая',
  'medium': 'Средняя',
  'hard': 'Сложная',
};
