import XCTest
@testable import MovieQuiz

class MovieLoaderTests: XCTestCase {
    func testSuccessLoad() throws {
        // Given
        let stubsNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubsNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies(ListsOfFilmsURL.mostPopularMoviesURL) { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.count, 2)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoad() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Load expectation")
        
        loader.loadMovies(ListsOfFilmsURL.mostPopularMoviesURL) { result in
            // Then
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error) :
                XCTAssertNotNil(error)
                expectation.fulfill()
                
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
