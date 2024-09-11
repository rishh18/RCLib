import XCTest
@testable import RCLib

struct MockData: Codable, Equatable {
    let id: Int
    let name: String
}

class URLProtocolMock: URLProtocol {
    // Static variables to hold mock responses, data, and errors
    static var testURLs = [URL?: Data]()
    static var response: HTTPURLResponse?
    static var error: Error?
    
    // Determines whether this URLProtocol subclass can handle the given request
    override class func canInit(with request: URLRequest) -> Bool {
        // Always return true to handle all requests in the mock
        return true
    }
    
    // Returns the canonical request for the given request
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Simply return the request as-is
        return request
    }
    
    // Starts loading the request and simulates the network response
    override func startLoading() {
        // Check if the request has a URL
        if let url = request.url {
            // If there is mock data for the URL, load it
            if let data = URLProtocolMock.testURLs[url] {
                self.client?.urlProtocol(self, didLoad: data)
            } else {
                // If no mock data is found, load empty data
                self.client?.urlProtocol(self, didLoad: Data())
            }
            
            // If a mock response is set, send it
            if let response = URLProtocolMock.response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            // If a mock error is set, send it
            if let error = URLProtocolMock.error {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        // Notify the client that loading is complete
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    // Stops loading the request (no-op in the mock)
    override func stopLoading() { }
}

final class RCLibTests: XCTestCase {
    
    var networkManager: RCLib?
    var interactionManager: InteractionManager!
    var dataFetcher: DataFetcher!

    
    override func setUpWithError() throws {
        // Register the mock URL protocol
        let config = URLSessionConfiguration.default
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        networkManager = RCLib(url: URL(string: "https://api.example.com/mockdata")!, key: "mockData") {(result: Result<MockData, Error>) in
        }
        interactionManager = InteractionManager.shared
        dataFetcher = DataFetcher(session: session)
    }
    
    override func tearDownWithError() throws {
        networkManager = nil
        interactionManager = nil
    }
    
    func testFetchDataSuccess() throws {
        // Define the URL for the mock data
        let url = URL(string: "https://api.example.com/mockdata")!
        // Create a mock data object
        let mockData = MockData(id: 1, name: "Test Name")
        // Encode the mock data to JSON
        let mockJSON = try JSONEncoder().encode(mockData)
        
        // Mock URLSession response
        // Set the URL and corresponding mock JSON data
        URLProtocolMock.testURLs = [url: mockJSON]
        // Set the HTTP response to indicate success (status code 200)
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        // Ensure no error is returned
        URLProtocolMock.error = nil
        
        // Create an expectation for the asynchronous fetch operation
        let expectation = self.expectation(description: "Fetching data succeeds")
        
        // Call the fetchJSON method from the network manager
        dataFetcher.fetchJSON(from: url, forKey: "mockData") { (result: Result<MockData, Error>) in
            switch result {
            case .success(let data):
                // Verify that the fetched data matches the mock data
                XCTAssertEqual(data, mockData, "Fetched data should match the mock data")
                expectation.fulfill()
            case .failure(let error):
                // If an error occurs, fail the test
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        // Wait for the expectations to be fulfilled or timeout
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchDataNetworkFailure() throws {
        // Define the URL for the mock data
        let url = URL(string: "https://api.example.com/mockdata")!
        
        // Mock URLSession network error
        // Set the URL with an empty Data object to simulate a network error
        URLProtocolMock.testURLs = [url: Data()]
        
        // Set the HTTP response to indicate success (status code 200), but this won't matter due to the error
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // Simulate a network error with a specific domain and code
        URLProtocolMock.error = NSError(domain: "NetworkError", code: -1001, userInfo: nil)
        
        // Create an expectation for the asynchronous fetch operation
        let expectation = self.expectation(description: "Fetching data fails due to network error")
        
        // Call the fetchJSON method from the network manager
        dataFetcher.fetchJSON(from: url, forKey: "mockData") { (result: Result<MockData, Error>) in
            switch result {
            case .success:
                // If the fetch succeeds, fail the test since a network error was expected
                XCTFail("Expected failure, got success")
            case .failure(let error):
                // If a failure occurs, ensure the error is not nil
                XCTAssertNotNil(error, "Expected error, got nil")
                // Fulfill the expectation indicating the test has completed
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled or timeout
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchDataDecodingFailure() throws {
        // Define the URL for the mock data
        let url = URL(string: "https://api.example.com/mockdata")!
        
        // Create invalid JSON data
        let invalidJSON = Data("invalid json".utf8)
        
        // Mock URLSession response with invalid JSON
        // Set the URL and corresponding invalid JSON data
        URLProtocolMock.testURLs = [url: invalidJSON]
        
        // Set the HTTP response to indicate success (status code 200)
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // Ensure no error is returned
        URLProtocolMock.error = nil
        
        // Create an expectation for the asynchronous fetch operation
        let expectation = self.expectation(description: "Fetching data fails due to decoding error")
        
        // Call the fetchJSON method from the network manager
        dataFetcher.fetchJSON(from: url, forKey: "mockData") { (result: Result<MockData, Error>) in
            switch result {
            case .success:
                // If the fetch succeeds, fail the test since a decoding error was expected
                XCTFail("Expected failure, got success")
            case .failure(let error):
                // If a failure occurs, ensure the error is not nil
                XCTAssertNotNil(error, "Expected error, got nil")
                // Fulfill the expectation indicating the test has completed
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled or timeout
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testFetchDataNilData() throws {
        // Define the URL for the mock data
        let url = URL(string: "https://api.example.com/mockdata")!
        
        // Mock URLSession response with empty data
        // Set the URL with an empty Data object to simulate a nil data response
        URLProtocolMock.testURLs = [url: Data()]
        
        // Set the HTTP response to indicate success (status code 200)
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // Ensure no error is returned
        URLProtocolMock.error = nil
        
        // Create an expectation for the asynchronous fetch operation
        let expectation = self.expectation(description: "Fetching data fails due to nil data response")
        
        // Call the fetchJSON method from the network manager
        dataFetcher.fetchJSON(from: url, forKey: "mockData") { (result: Result<MockData, Error>) in
            switch result {
            case .success:
                // If the fetch succeeds, fail the test since a nil data response was expected
                XCTFail("Expected failure, got success")
            case .failure(let error):
                // If a failure occurs, ensure the error is not nil
                XCTAssertNotNil(error, "Expected error, got nil")
                // Fulfill the expectation indicating the test has completed
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled or timeout
        waitForExpectations(timeout: 5, handler: nil)
    }

    
    func testStoreAndRetrieveData() throws {
        // Define the key to be used for storing and retrieving data
        let key = "testDataKey"
        
        // Create mock data to be stored
        let mockData = MockData(id: 1, name: "Test Name")
        
        // Store the mock data using the InteractionManager
        interactionManager.storeValue(mockData, forKey: key)
        
        // Retrieve the data from the InteractionManager using the same key
        guard let retrievedData = interactionManager.retrieveValue(forKey: key, type: MockData.self) else {
            // Fail the test if the data could not be retrieved
            XCTFail("Expected to retrieve MockData")
            return
        }
        
        // Verify that the retrieved data matches the originally stored data
        XCTAssertEqual(retrievedData, mockData, "Stored data should be equal to retrieved data")
    }
    
    func testStoreAndRetrieveString() throws {
        // Define the key to be used for storing and retrieving the string
        let key = "testStringKey"
        
        // Create a string value to be stored
        let value = "Test String"
        
        // Store the string value using the InteractionManager
        interactionManager.storeValue(value, forKey: key)
        
        // Retrieve the string value from the InteractionManager using the same key
        guard let retrievedValue = interactionManager.retrieveValue(forKey: key, type: String.self) else {
            // Fail the test if the string value could not be retrieved
            XCTFail("Expected to retrieve String")
            return
        }
        
        // Verify that the retrieved string matches the originally stored string
        XCTAssertEqual(retrievedValue, value, "Stored string should be equal to retrieved string")
    }
    
    func testRetrieveNonExistentData() throws {
        // Define a key that does not exist in storage
        let key = "nonExistentKey"
        
        // Attempt to retrieve data using the non-existent key
        let retrievedValue: String? = interactionManager.retrieveValue(forKey: key, type: String.self)
        
        // Assert that the retrieved value is nil, as expected for a non-existent key
        XCTAssertNil(retrievedValue, "Retrieving non-existent data should return nil")
    }
    
    func testOverwriteExistingData() throws {
        // Define a key and initial value to store
        let key = "testOverwriteKey"
        let initialValue = "Initial Value"
        let newValue = "New Value"
        
        // Store the initial value using InteractionManager
        interactionManager.storeValue(initialValue, forKey: key)
        
        // Retrieve the stored initial value and ensure it matches the original initial value
        guard let initialRetrievedValue = interactionManager.retrieveValue(forKey: key, type: String.self) else {
            XCTFail("Expected to retrieve initial String")
            return
        }
        XCTAssertEqual(initialRetrievedValue, initialValue, "Stored initial value should be equal to retrieved initial value")
        
        // Store the new value using the same key, effectively overwriting the initial value
        interactionManager.storeValue(newValue, forKey: key)
        
        // Retrieve the stored new value and ensure it matches the new value
        guard let newRetrievedValue = interactionManager.retrieveValue(forKey: key, type: String.self) else {
            XCTFail("Expected to retrieve new String")
            return
        }
        XCTAssertEqual(newRetrievedValue, newValue, "Stored new value should be equal to retrieved new value")
    }
    
    func testRemoveData() throws {
        // Define a key and a value to store
        let key = "testRemoveKey"
        let value = "Test Value"
        
        // Store the value using InteractionManager
        interactionManager.storeValue(value, forKey: key)
        
        // Retrieve the stored value and ensure it matches the original value
        guard let retrievedValue = interactionManager.retrieveValue(forKey: key, type: String.self) else {
            XCTFail("Expected to retrieve String")
            return
        }
        XCTAssertEqual(retrievedValue, value, "Stored value should be equal to retrieved value")
        
        // Remove the value from UserDefaults
        UserDefaults.standard.removeObject(forKey: key)
        
        // Attempt to retrieve the value again, expecting it to be nil
        let removedValue: String? = interactionManager.retrieveValue(forKey: key, type: String.self)
        XCTAssertNil(removedValue, "Removed value should be nil")
    }
    
    func testRetrieveCachedData() throws {
        let key = "testCachedDataKey"
        let mockData = MockData(id: 1, name: "Test Name")
        
        // Store mock data in InteractionManager
        InteractionManager.shared.storeValue(mockData, forKey: key)
        
        // Retrieve the data using NetworkManager's method
        let retrievedData: MockData? = networkManager?.retrieveCachedData(forKey: key, type: MockData.self)
        
        // Verify the retrieved data matches the stored data
        XCTAssertEqual(retrievedData, mockData, "Stored data should be equal to retrieved data")
    }
    
    func testRetrieveCachedDataNotFound() throws {
        let key = "nonexistentKey"
        
        // Try to retrieve data that doesn't exist
        let retrievedData: MockData? = networkManager?.retrieveCachedData(forKey: key, type: MockData.self)
        
        // Verify that the retrieved data is nil
        XCTAssertNil(retrievedData, "Retrieved data should be nil for a nonexistent key")
    }
    
    func testRetrieveDataDecodingError() throws {
        // Define a key for storing data
        let key = "testDecodingErrorKey"
        
        // Create a mock data object and store it
        let mockData = MockData(id: 1, name: "Test Name")
        interactionManager.storeValue(mockData, forKey: key)
        
        // Attempt to retrieve the stored data as a different type (String instead of MockData)
        // This should fail and trigger the catch block
        let retrievedData: String? = interactionManager.retrieveValue(forKey: key, type: String.self)
        
        // Verify that the retrieved data is nil due to the decoding error
        XCTAssertNil(retrievedData, "Decoding should fail, resulting in a nil return value")
    }
    
    func testNoDataReceived() throws {
        // Define the URL for the mock data
        let url = URL(string: "https://api.example.com/nodata")!
        
        // Mock URLSession response with no data
        URLProtocolMock.testURLs = [url: Data()] // Provide empty Data instead of nil
        
        // Set the HTTP response to indicate success (status code 200)
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // Ensure no error is returned
        URLProtocolMock.error = nil
        
        // Create an expectation for the asynchronous fetch operation
        let expectation = self.expectation(description: "Fetching data fails due to no data received")
        
        // Call the fetchJSON method from the dataFetcher
        dataFetcher.fetchJSON(from: url, forKey: "noDataKey") { (result: Result<MockData, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertNotNil(error, "Expected error, got nil")
                expectation.fulfill()
            }
        }
        
        // Wait for the expectations to be fulfilled or timeout
        waitForExpectations(timeout: 5, handler: nil)
    }

}
