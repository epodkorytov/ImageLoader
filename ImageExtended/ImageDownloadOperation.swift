//
//  ImageDownloadOperation.swift
//  ImageExtended
//


import UIKit

public protocol ImageDownloadDelegate {
    func imageDownloaderDelegate(_ downloader: ImageDownloadOperation, didReportProgress progress: Progress);
}

public class ImageDownloadOperation: Operation, URLSessionDownloadDelegate {
    
//    MARK: - Variables
    
    private var imageURL: URL
    private var session: Foundation.URLSession?
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?
    private let progress: Progress = Progress()
    
    public var completionHandler: ImageDownloaderCompletion?
    
    public var httpAdditionalHeaders: [AnyHashable: Any]?
    
    private var _finished = false
    
    var delegate: ImageDownloadDelegate?
    
//    MARK: - Instance initialiazations
    
    public init(imageURL: URL) {
        self.imageURL = imageURL
        super.init()
    }

    
//    MARK: - Overriden methods
    
    public override func start() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = httpAdditionalHeaders
        session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self,
                                        delegateQueue: OperationQueue.main)
        
        resumeDownload()
    }
    
    public override func cancel() {
        task?.cancel { [weak self] data in
            self?.resumeData = data
            self?.isFinished = true
        }
    }
    
    
     public override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    
//    MARK: - Private methods
    
    private func resumeDownload() {
        let newTask: URLSessionDownloadTask?
        if let resumeData = resumeData {
            newTask = session?.downloadTask(withResumeData: resumeData)
        } else {
            newTask = session?.downloadTask(with: imageURL)
        }
        newTask?.resume()
        task = newTask
    }
    

//    MARK: - Delegated methods
    
//    MARK: URLSessionDownloadDelegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        progress.totalUnitCount = totalBytesExpectedToWrite
        progress.completedUnitCount = totalBytesWritten
        delegate?.imageDownloaderDelegate(self, didReportProgress: progress)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL)
    {
        defer {
            session.finishTasksAndInvalidate()
        }
        do {
            let newData = try Data(contentsOf: location, options: .mappedIfSafe)
            let newImage = UIImage.imageWithCachedData(newData)
            let newImageInstance = ImageInstance(image: newImage, data: newData, state: .new, url: imageURL)
            if isCancelled {
                return
            }
            if newImage == nil {
                completionHandler?(nil, NSError(domain: "",
                                                code: 1003,
                                                userInfo: [NSLocalizedFailureErrorKey: "There is no image on the giving URL"]))
            } else {
                completionHandler?(newImageInstance, nil)
            }
        } catch let error as NSError {
            if isCancelled {
                return
            }
            completionHandler?(nil, error)
        }
        isFinished = true
    }

    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            session.finishTasksAndInvalidate()
        }
        if let error = error {
            if isCancelled {
                isFinished = true
                return
            }
            completionHandler?(nil, error as NSError?)
            isFinished = true
        }
    }

    
    public func urlSession(_ session: URLSession, task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
                           completionHandler: @escaping (URLRequest?) -> Void)
    {
        self.completionHandler?(nil, nil)
        imageURL = request.url!
        resumeDownload()
    }
    
}
