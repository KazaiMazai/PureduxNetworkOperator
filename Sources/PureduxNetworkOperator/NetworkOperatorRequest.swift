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
        public init(id: UUID,
                    request: URLRequest,
                    taskType: TaskType,
                    handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.id = id
            self.request = request
            self.taskType = taskType
            self.handler = handler
        }

        public let id: UUID
        public let request: URLRequest
        public let taskType: TaskType
        public let handler: (Data?, URLResponse?, Error?) -> Void
    }

    public enum TaskType {
        case dataTask
    }
}

extension NetworkOperator.Request: OperatorRequest {
    public func handle(_ result: TaskResult<(Data?, URLResponse?, Error?)>) {
        switch result {
        case let .success((data, response, error)):
            handler(data, response, error)
        case .cancelled:
            break
        case .error(let error):
            handler(nil, nil, error)
        }
    }
}
