//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation
import PureduxSideEffects

extension URLSessionTask: OperatorTask { }

public typealias NetworkTaskResult = TaskResult<(Data?, URLResponse?, Error?), NetworkOperator.TaskStatusType>
typealias NetworkTaskResultHandler = (NetworkTaskResult) -> Void

public final class NetworkOperator: Operator<NetworkOperator.Request, URLSessionTask> {
    private var taskResultHandlers: [Int: NetworkTaskResultHandler] = [:]
    private let configuration: URLSessionConfiguration
    private lazy var urlSessionDelegate: URLSessionDelegate = makeURLSessionDelegate()
    private lazy var session: URLSession = {
        URLSession(
            configuration: configuration,
            delegate: urlSessionDelegate,
            delegateQueue: nil)
    }()

    public init(configuration: URLSessionConfiguration = .default,
                label: String = "Network",
                qos: DispatchQoS = .utility,
                logger: Logger = .console(.info)) {

        self.configuration = configuration
        super.init(label: label, qos: qos, logger: logger)
    }

    public override func createTaskFor(_ request: Request,
                                       with taskResultHandler: @escaping (NetworkTaskResult) -> Void) -> URLSessionTask {

        let task: URLSessionTask

        switch request.taskType {
        case .dataTask:
            logger.log(.debug, "\(request.request.httpMethod ?? "") \(request.request)")
            if let httpBody = request.request.httpBody {
                logger.log(.trace, msg: "Body:", with: httpBody)
            }

            task = session.dataTask(with: request.request) { data, response, error in
                taskResultHandler(.success((data, response, error)))
            }

            taskResultHandlers[task.taskIdentifier] = taskResultHandler
        }

        return task
    }

    public override func run(task: URLSessionTask,
                             for request: NetworkOperator.Request) {
        task.resume()
    }
}

private extension NetworkOperator {
    func makeURLSessionDelegate() -> URLSessionDelegate {
        if #available(iOS 11.0, *) {
            return makeURLSessionDelegate_iOS11()
        }

        return makeURLSessionDelegate_iOS7()
    }

    @available(iOS 11.0, *)
    func makeURLSessionDelegate_iOS11() -> URLSessionDelegate {
        let delegate = URLSessionDelegateProxy_iOS11()
        setHandlers_iOS7(delegate: delegate)
        setHandlers_iOS11(delegate: delegate)
        return delegate
    }

    func makeURLSessionDelegate_iOS7() -> URLSessionDelegate {
        let delegate = URLSessionDelegateProxy_iOS7()
        setHandlers_iOS7(delegate: delegate)
        return delegate
    }
}

private extension NetworkOperator {
    func setHandlers_iOS7<Delegate: URLSessionDelegateProxy_iOS7>(delegate: Delegate) {
        delegate.didCompleteWithError = { [weak self] session, task, err in
            self?.taskResultHandlers[task.taskIdentifier] = nil
        }
    }

    @available(iOS 11.0, *)
    func setHandlers_iOS11<Delegate: URLSessionDelegateProxy_iOS11>(delegate: Delegate) {
        delegate.taskIsWaitingForConnectivity = { [weak self] _, task in
            guard let self = self else {
                return
            }

            guard let handler = self.taskResultHandlers[task.taskIdentifier] else {
                return
            }

            handler(.statusChanged(.taskStatus(.waitingForConnectivity)))
        }

        delegate.willBeginDelayedRequest = { [weak self] _, task, _, _ in
            guard let self = self else {
                return
            }

            guard let handler = self.taskResultHandlers[task.taskIdentifier] else {
                return
            }

            handler(.statusChanged(.taskStatus(.willBeginDelayedRequest)))
        }
    }
}
