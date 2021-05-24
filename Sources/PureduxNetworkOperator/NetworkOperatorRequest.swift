//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation
import PureduxSideEffects

extension NetworkOperator {
    public struct Request {
        public typealias RequestHandler = (Data?, URLResponse?, Error?) -> Void
        public typealias RequestStatusHandler = (TaskStatusType) -> Void

        public init(id: UUID,
                    request: URLRequest,
                    taskType: TaskType,
                    handler: @escaping RequestHandler,
                    statusHandler: RequestStatusHandler? = nil) {
            self.id = id
            self.request = request
            self.taskType = taskType
            self.handler = handler
            self.statusHandler = statusHandler
        }

        public let id: UUID
        public let request: URLRequest
        public let taskType: TaskType
        public let handler: RequestHandler
        public let statusHandler: RequestStatusHandler?
    }

    public enum TaskType {
        case dataTask
    }
}

extension NetworkOperator.Request: OperatorRequest {
    public func handle(_ result: NetworkTaskResult) {
        switch result {
        case let .success((data, response, error)):
            handler(data, response, error)
        case .cancelled:
            break
        case .statusChanged(let status):
            statusHandler?(status)
        case .failure(let error):
            handler(nil, nil, error)
        }
    }
}


public extension NetworkOperator {
    enum TaskStatusType {
        case taskStatus(TaskStatus)
    }

    enum TaskStatus {
        case waitingForConnectivity
        case willBeginDelayedRequest
    }
}
