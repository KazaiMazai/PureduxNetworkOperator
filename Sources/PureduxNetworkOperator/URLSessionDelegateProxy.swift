//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.05.2021.
//

import Foundation


extension NetworkOperator {
    @available(iOS 11.0, *)
    class URLSessionDelegateProxy_iOS11: NSObject {
        var taskIsWaitingForConnectivity: ((_ session: URLSession, _ task:  URLSessionTask) -> Void)?

        var willBeginDelayedRequest: ((URLSession,
                                       URLSessionTask,
                                       URLRequest,
                                       (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) -> Void)?

        var didCompleteWithError: ((URLSession, URLSessionTask, Error?) -> Void)?
    }

    class URLSessionDelegateProxy_iOS7: NSObject {

        var didCompleteWithError: ((URLSession, URLSessionTask, Error?) -> Void)?
    }
}

@available(iOS  11.0, *)
extension NetworkOperator.URLSessionDelegateProxy_iOS11: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        taskIsWaitingForConnectivity?(session, task)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        willBeginDelayedRequest?(session, task, request, completionHandler)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        didCompleteWithError?(session, task, error)
    }
}

extension NetworkOperator.URLSessionDelegateProxy_iOS7: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        didCompleteWithError?(session, task, error)
    }
}
