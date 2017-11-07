import Foundation
import XCTest
@testable import Molib

class DownloaderOperationTests: XCTestCase {


    let downloadURL = URL(string: "http://testurl.com/file1")
    let localDownloadURL = URL(string: "file:/root/testFile.vid")

    var mockNetworkOperationService = MockNetworkService()
    var exampleDownloadTask: DownloaderTask!
    var operation: DownloaderOperation!

    override func setUp() {
        super.setUp()

        mockNetworkOperationService = MockNetworkService()
        exampleDownloadTask = DownloaderTask(downloadURL: downloadURL!, downloadDestinationURL: localDownloadURL!, fileName: "TestFile")
        operation = DownloaderOperation(downloaderTask: exampleDownloadTask, networkOperationService: mockNetworkOperationService)

    }
    func testInit() {
        let operation = DownloaderOperation(downloaderTask: exampleDownloadTask, networkOperationService: mockNetworkOperationService)
        XCTAssertNotNil(operation)
    }

    func testWhenOperationStartsDelegateDidStartDownloadIsCalled() {
        let mockDelegate = MockDownloadOperationDelegate()
        operation.delegate = mockDelegate
        operation.main()
        XCTAssertTrue(mockDelegate.delegateStartCalled)
    }

    func testWhenOperationCompletesDelegateDidCompleteIsCalled() {
        let mockDelegate = MockDownloadOperationDelegate()
        operation.delegate = mockDelegate
        operation.main()
        XCTAssertTrue(mockDelegate.delegateCompleteCalled)
    }
}

class MockDownloadOperationDelegate: DownloaderOperationDelegate {

    var delegateStartCalled = false
    var delegateUpdateProgress: Float = 0.0
    var delegateCompleteCalled = false
    var delegateFailedError: Error? = nil
    var updatedTask: DownloaderTask? = nil

    func downloaderOperationDidUpdateProgress(progress: Float, forTask task: DownloaderTask) {
        updatedTask = task
        delegateUpdateProgress = progress
    }

    func downloaderOperationDidStartDownload(forTask task: DownloaderTask) {
        updatedTask = task
        delegateStartCalled = true
    }

    func downloaderOperationDidFailDownload(withError error: Error, forTask task: DownloaderTask) {
        updatedTask = task
        delegateFailedError = error
    }

    func downloaderOperationDidComplete(forTask task: DownloaderTask) {
        updatedTask = task
        delegateCompleteCalled = true
    }
}

