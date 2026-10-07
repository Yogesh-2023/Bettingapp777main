// File: lib/HomeScreen/CricketQuizWidget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

// ---------------- Quiz Data Models ----------------
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final bool isWinner;
  final String message;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.isWinner,
    required this.message,
  });

  double get percentage => (score / totalQuestions) * 100;
}

// ---------------- Cricket Quiz Questions ----------------
class CricketQuizData {
  /// Get current day of week (1 = Monday, 7 = Sunday)
  static int _getCurrentDayOfWeek() {
    return DateTime.now().weekday;
  }

  /// Get questions based on day of week
  /// Monday and Wednesday show different questions
  static List<QuizQuestion> getQuestions() {
    final dayOfWeek = _getCurrentDayOfWeek();
    
    // Monday = 1, Wednesday = 3
    if (dayOfWeek == 1 || dayOfWeek == 3) {
      log('📅 Loading Monday/Wednesday questions (Day: $dayOfWeek)');
      return _getMondayWednesdayQuestions();
    }
    
    log('📅 Loading default questions (Day: $dayOfWeek)');
    return _getDefaultQuestions();
  }

  /// Default questions (Tuesday, Thursday, Friday, Saturday, Sunday)
  static List<QuizQuestion> _getDefaultQuestions() {
    return [
      QuizQuestion(
        question: "Who holds the record for most runs in ODI cricket?",
        options: [
          "Sachin Tendulkar",
          "Ricky Ponting",
          "Virat Kohli",
          "Kumar Sangakkara",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which country won the ICC Cricket World Cup 2019?",
        options: [
          "India",
          "Australia",
          "England",
          "New Zealand",
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: "What is the maximum number of overs in a Test match innings?",
        options: [
          "90 overs",
          "Unlimited",
          "50 overs",
          "20 overs",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "Who is known as the 'God of Cricket'?",
        options: [
          "Virat Kohli",
          "Sachin Tendulkar",
          "MS Dhoni",
          "Ricky Ponting",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What is the highest individual score in Test cricket?",
        options: [
          "400* by Brian Lara",
          "375 by Brian Lara",
          "400* by Matthew Hayden",
          "380 by Mahela Jayawardene",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which bowler has taken the most wickets in Test cricket?",
        options: [
          "Shane Warne",
          "Muttiah Muralitharan",
          "Anil Kumble",
          "James Anderson",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What is the length of a cricket pitch?",
        options: [
          "20 yards (18.29 meters)",
          "22 yards (20.12 meters)",
          "24 yards (21.95 meters)",
          "18 yards (16.46 meters)",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "Who scored the fastest century in ODI cricket?",
        options: [
          "AB de Villiers",
          "Shahid Afridi",
          "Corey Anderson",
          "James Faulkner",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which team has won the most ICC Cricket World Cups?",
        options: [
          "India",
          "Australia",
          "West Indies",
          "Pakistan",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What is the maximum number of players allowed in a cricket team?",
        options: [
          "10 players",
          "11 players",
          "12 players",
          "15 players",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "Who is the only batsman to score 100 international centuries?",
        options: [
          "Ricky Ponting",
          "Sachin Tendulkar",
          "Virat Kohli",
          "Jacques Kallis",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What does 'LBW' stand for in cricket?",
        options: [
          "Leg Before Wicket",
          "Long Ball Wide",
          "Left Behind Wicket",
          "Leg By Wicket",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which format of cricket is played with a pink ball?",
        options: [
          "ODI",
          "T20",
          "Test (Day-Night)",
          "All formats",
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: "Who is known as 'Captain Cool' in Indian cricket?",
        options: [
          "Virat Kohli",
          "MS Dhoni",
          "Sourav Ganguly",
          "Rahul Dravid",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What is the minimum score required to win a Test match?",
        options: [
          "1 run",
          "10 runs",
          "50 runs",
          "100 runs",
        ],
        correctAnswerIndex: 0,
      ),
    ];
  }

  /// Monday and Wednesday specific questions
  static List<QuizQuestion> _getMondayWednesdayQuestions() {
    return [
      QuizQuestion(
        question: "Which Indian batsman scored the first double century in ODI cricket?",
        options: [
          "Sachin Tendulkar",
          "Virender Sehwag",
          "Rohit Sharma",
          "Virat Kohli",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "What is the highest team score in T20 International cricket?",
        options: [
          "263 by Australia",
          "278 by Afghanistan",
          "260 by Sri Lanka",
          "245 by India",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "Who is the only player to score 10,000+ runs in both Test and ODI cricket?",
        options: [
          "Sachin Tendulkar",
          "Ricky Ponting",
          "Jacques Kallis",
          "Kumar Sangakkara",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which bowler has the best bowling figures in ODI cricket (10 wickets)?",
        options: [
          "Chaminda Vaas",
          "Shahid Afridi",
          "Glenn McGrath",
          "Muttiah Muralitharan",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "What is the fastest T20 century in international cricket?",
        options: [
          "47 balls by AB de Villiers",
          "45 balls by Rohit Sharma",
          "35 balls by Yuvraj Singh",
          "50 balls by Chris Gayle",
        ],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: "Which team won the first T20 World Cup in 2007?",
        options: [
          "Australia",
          "India",
          "Pakistan",
          "South Africa",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "Who is the only captain to win all three ICC trophies (World Cup, T20 World Cup, Champions Trophy)?",
        options: [
          "Ricky Ponting",
          "MS Dhoni",
          "Clive Lloyd",
          "Imran Khan",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What is the maximum number of runs scored in a single over in international cricket?",
        options: [
          "36 runs",
          "28 runs",
          "30 runs",
          "32 runs",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which Indian bowler took a hat-trick in the 2011 World Cup?",
        options: [
          "Zaheer Khan",
          "Harbhajan Singh",
          "Ashish Nehra",
          "Yuvraj Singh",
        ],
        correctAnswerIndex: 3,
      ),
      QuizQuestion(
        question: "What is the highest partnership in Test cricket?",
        options: [
          "624 by Sangakkara & Jayawardene",
          "576 by Hayden & Langer",
          "415 by Dravid & Laxman",
          "467 by Tendulkar & Dravid",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Who is the fastest bowler to reach 100 wickets in Test cricket?",
        options: [
          "George Lohmann",
          "Shane Warne",
          "Muttiah Muralitharan",
          "Dennis Lillee",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which country has never won an ICC Cricket World Cup?",
        options: [
          "South Africa",
          "New Zealand",
          "Pakistan",
          "West Indies",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "What is the highest individual score in T20 International cricket?",
        options: [
          "172* by Aaron Finch",
          "175* by Evin Lewis",
          "158* by Brendon McCullum",
          "156* by Chris Gayle",
        ],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Who is known as 'Rawalpindi Express' in cricket?",
        options: [
          "Wasim Akram",
          "Shoaib Akhtar",
          "Waqar Younis",
          "Mohammad Amir",
        ],
        correctAnswerIndex: 1,
      ),
      QuizQuestion(
        question: "What is the minimum number of overs required to constitute a valid ODI match?",
        options: [
          "20 overs",
          "25 overs",
          "30 overs",
          "40 overs",
        ],
        correctAnswerIndex: 0,
      ),
    ];
  }
}

// ---------------- Cricket Quiz Widget ----------------
class CricketQuizWidget extends StatefulWidget {
  const CricketQuizWidget({super.key});

  @override
  State<CricketQuizWidget> createState() => _CricketQuizWidgetState();
}

class _CricketQuizWidgetState extends State<CricketQuizWidget> {
  final List<QuizQuestion> _questions = CricketQuizData.getQuestions();
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _quizCompleted = false;
  final List<int> _userAnswers = [];

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex == null) return;

    // Save user's answer
    _userAnswers.add(_selectedAnswerIndex!);

    // Check if answer is correct
    if (_selectedAnswerIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
      });
    } else {
      // Quiz completed
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _score = 0;
      _quizCompleted = false;
      _userAnswers.clear();
    });
  }

  QuizResult _calculateResult() {
    final percentage = (_score / _questions.length) * 100;
    final isWinner = percentage >= 60; // 60% or above is winner
    String message;

    if (percentage >= 90) {
      message = "🏆 Outstanding! You're a Cricket Master!";
    } else if (percentage >= 75) {
      message = "🎉 Excellent! Great Cricket Knowledge!";
    } else if (percentage >= 60) {
      message = "✅ Good Job! You're a Winner!";
    } else if (percentage >= 40) {
      message = "😊 Not Bad! Keep Learning!";
    } else {
      message = "📚 Keep Practicing! You'll Improve!";
    }

    return QuizResult(
      score: _score,
      totalQuestions: _questions.length,
      isWinner: isWinner,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      final result = _calculateResult();
      return _buildResultScreen(result);
    }

    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🏏 Cricket Quiz",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B1223),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1223),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentQuestionIndex + 1}/${_questions.length}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B1223)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Question
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswerIndex == index;
            final isCorrect = index == question.correctAnswerIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectAnswer(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswerIndex == null ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1223),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                _currentQuestionIndex < _questions.length - 1 ? "Next Question" : "Finish Quiz",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(QuizResult result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Result Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: result.isWinner ? Colors.green.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.isWinner ? Icons.emoji_events : Icons.sentiment_neutral,
              size: 60,
              color: result.isWinner ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 20),

          // Result Message
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: result.isWinner ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 24),

          // Score Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1223),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "Your Score",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${result.score}/${result.totalQuestions}",
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${result.percentage.toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Winner/Loser Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: result.isWinner ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: result.isWinner ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  result.isWinner ? Icons.check_circle : Icons.cancel,
                  color: result.isWinner ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  result.isWinner ? "WINNER" : "BETTER LUCK NEXT TIME",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: result.isWinner ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Restart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1223),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                "Play Again",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
