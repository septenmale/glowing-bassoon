import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Public Properties
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    var alertPresenter: AlertPresenter?
    var questionFactory: QuestionFactory?
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private let statisticService: StatisticService!
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation() 
        
        questionFactory = QuestionFactoryImplementation(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: viewController)
    }
    
    // MARK: - Public Methods
    func didLoadDataFromServer() {
        viewController?.setLoadingIndicator(visible: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - Private Methods
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func didAnswerCorrectly(isCorrectAnswer: Bool) {
        if isCorrectAnswer == true {
            correctAnswers += 1 }
    }
    
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.changeButtonState(isEnabled: false)
        didAnswerCorrectly(isCorrectAnswer: isCorrect)
        viewController?.hightLightImageBorder(isCorrectAnswerReceived: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        viewController?.hideLayerBorders()
        viewController?.changeButtonState(isEnabled: true)
        
        if isLastQuestion() {
            
            let title = "This round is over"
            
            statisticService.store (
                correct: correctAnswers,
                total: questionsAmount
            )
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let message =
"""
Your result: \(correctAnswers)/\(questionsAmount)
Number of quizzes played: \(gamesCount)
Your record: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
Average accuracy: \(String(format: "%.2f", totalAccuracy))%
"""
            let model = AlertModel(
                title: title,
                message: message,
                buttonText: "Play again",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.restartGame()
                    self.questionFactory?.requestNextQuestion()
                    viewController?.setLoadingIndicator(visible: false)
                }
            )
            
            alertPresenter?.showAlert(model: model)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
