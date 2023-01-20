//
//  ServerError.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/18/22.
//

import Foundation
import SocketIO

let TEST: Bool = false;
let TEST_TIME_LEFT = 60 * 3;

enum ServerCode: Int {
    case ok = 200
    case badRequest = 400
    case unauthorized = 401
    case internalServer = 500
}

enum ServerError: Error {
    case badRequest(msg: String)
    case unauthorized
    case internalServer
}

enum RequestType: String {
    case post = "POST"
    case get = "GET"
}

func sendRequest(url: String, body: [String: String]?, type: RequestType) async throws -> Data {
    if !TEST {
        let url = URL(string: "https://language-study-backend-production.up.railway.app/api/\(url)")!
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        if let body = body {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = bodyData
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as! HTTPURLResponse
        let code = ServerCode(rawValue: httpResponse.statusCode)!
        switch code {
        case .ok:
            return data
        case .badRequest:
            throw ServerError.badRequest(msg: String(decoding: data, as: UTF8.self))
        case .unauthorized:
            throw ServerError.unauthorized
        case .internalServer:
            throw ServerError.internalServer
        }
    } else {
        return Data()
    }
    
}

class WebSocket: NSObject {
    static let URL_STRING = "wss://language-study-backend-production.up.railway.app/api/ws"
    static let instance = WebSocket()
    
    public var isOpen = false
    
    private var socket: URLSessionWebSocketTask?
    private var handlers = [WebSocketEvent: [Int: (String) -> ()]]()
    
    override init() {
        super.init()
    }
    
    func connect() {
        
        if TEST {
            isOpen = true
            Task {
                sleep(10)
                receiveMessage()
            }
        } else {
            let url = URL(string: WebSocket.URL_STRING)!
            
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default)
            socket = session.webSocketTask(with: request)
            socket?.resume()
            isOpen = true
            receiveMessage()
        }
    }
    
    func disconnect() {
        if TEST {
            isOpen = false
        } else {
            socket?.cancel(with: .goingAway, reason: nil)
            socket = nil
            isOpen = false
        }
    }
    
    // TODO resused unregistered ids
    func registerHandler(event: WebSocketEvent, handler: @escaping (String) -> ()) -> Int {
        let id: Int
        if handlers[event] == nil {
            handlers[event] = [:]
            id = 0
        } else {
            id = handlers[event]!.first == nil ? 0 : handlers[event]!.first!.key + 1
        }
        
        handlers[event]![id] = handler
        return id
    }
    
    func unregisterHandler(event: WebSocketEvent, id: Int) {
        handlers[event]?.removeValue(forKey: id)
    }
    
    func sendMessage(event: WebSocketEvent, data: String) {
        if TEST {
            
        } else {
            let message = URLSessionWebSocketTask.Message.string("\(event.rawValue):\(data)")
            socket?.send(message, completionHandler: { error in
                if let error = error {
                    print("ERROR SENDING DATA \(error)")
                }
            })
        }
    }
    
    func receiveMessage() {
        if TEST {
            // start event
            Task {
                let event = WebSocketEvent.start
                let data = ""
                if let callbacks = self.handlers[event] {
                    for handler in callbacks {
                        handler.value(data)
                    }
                }
                let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    if TEST_TIME_LEFT <= 0 {
                        timer.invalidate()
                    }
                }
            }
            
        } else {
            socket?.receive(completionHandler: { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let message):
                    switch message {
                    case .string(let msg):
                        let i = msg.firstIndex(of: ":")!
                        let event = WebSocketEvent(rawValue: String(msg[..<i]))!
                        var data = String(msg[msg.index(after: i)...])
                        
                        if case .question = event {
                            var str = ""
                            
                            let i1 = data.index(after: data.firstIndex(of: "\"")!)
                            let i2 = data.lastIndex(of: "\"")!
                            let unicode = data[i1..<i2]
                            
                            for character in unicode.components(separatedBy: "\\u").dropFirst() {
                                let hex = Int(character, radix: 16)!
                                str += String(Unicode.Scalar(hex)!)
                                
                            }
                            data = String(data[..<i1]) + str + String(data[i2...])
                        }
                        
                        if let callbacks = self?.handlers[event] {
                            for handler in callbacks {
                                handler.value(data)
                            }
                        }
                    case .data(let data):
                        print("data", data.description)
                    default:
                        print("Unkown data type recieved from socket")
                    }
                }
                self?.receiveMessage()
            })
        }
    }
}

enum WebSocketEvent: String {
    case question = "question"
    case time = "time"
    case start = "start"
    case stop = "stop"
    case answer = "answer"
    case done = "done"
    case correct = "correct"
}
