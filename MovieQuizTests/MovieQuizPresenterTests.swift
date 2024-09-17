import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: UIViewController, MovieQuizViewControllerProtocol {
    func changeButtonState(isEnabled: Bool) {
        
    }
    
    func hideLayerBorders() {
        
    }
    
    func show(quiz step: QuizStepViewModel) {
        
    }
    func hightLightImageBorder(isCorrectAnswerReceived: Bool) {
        
    }
    func setLoadingIndicator(visible: Bool) {
        
    }
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}