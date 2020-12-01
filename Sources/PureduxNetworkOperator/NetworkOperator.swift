//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Foundation
import PureduxSideEffects

extension URLSessionTask: OperatorTask { }

public final class NetworkOperator: Operator<NetworkOperator.Request, URLSessionTask> {
    private let session: URLSession

    public init(configuration: URLSessionConfiguration = .default,
                queueLabel: String = "Network operator",
                qos: DispatchQoS = .utility,
                logging: LogSource = .defaultLogging()) {
        session = URLSession(configuration: configuration)
        super.init(queueLabel: queueLabel, qos: qos, logging: logging)
    }

    public override func createTaskFor(_ request: Request,
                                with completeHandler: @escaping (OperatorResult<(Data?, URLResponse?, Error?)>) -> Void) -> URLSessionTask {

        let task: URLSessionTask
        switch request.taskType {
        case .dataTask:
            logging.log(.debug, "\(request.request.httpMethod ?? "") \(request.request)")
            if let httpBody = request.request.httpBody {
                logging.log(.trace, msg: "Body:", with: httpBody)
            }

            task = session.dataTask(with: request.request) { data, response, error in
                completeHandler(.success((data, response, error)))
            }
        }

        return task
    }

    public override func run(task: URLSessionTask, for request: NetworkOperator.Request) {
        task.resume()
    }
}
