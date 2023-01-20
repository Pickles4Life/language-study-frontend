//
//  Friends.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/19/22.
//

import Foundation

let TEST_USERS = [
    User(id: UUID(), username: "test1", phoneNumber: "9785326542", streak: 4),
    User(id: UUID(), username: "test2", phoneNumber: "9785326541", streak: 2),
    User(id: UUID(), username: "test3", phoneNumber: "9785326543", streak: 7),
    User(id: UUID(), username: "test4", phoneNumber: "9785326544", streak: 0)
]

let TEST_REQUESTS = [
    User(id: UUID(), username: "test5", phoneNumber: "9785326512", streak: 2),
    User(id: UUID(), username: "test6", phoneNumber: "9785326521", streak: 8),
    User(id: UUID(), username: "test7", phoneNumber: "9785326533", streak: 3),
    User(id: UUID(), username: "test8", phoneNumber: "9785326554", streak: 1)
]

struct Friends: Codable {
    let friends: [User]
    let requests: [User]
    
    static func fetchFriends() async throws -> Friends {
        if !TEST {
            let data = try await sendRequest(url: "friend/get_friends", body: nil, type: .get)
            let jsonDecoder = JSONDecoder()
            let friends = try jsonDecoder.decode(Friends.self, from: data)
            return friends
        } else {
            return Friends(friends: TEST_USERS, requests: TEST_REQUESTS)
        }
    }
    
    static func sendFriendRequest(id: UUID) async throws {
        if !TEST {
            let body = ["id": "\(id)"]
            let _ = try await sendRequest(url: "friend/send_request", body: body, type: .post)
        }
    }
    
    static func acceptFriendRequest(id: UUID) async throws {
        if !TEST {
            let body = ["id": "\(id)"]
            let _ = try await sendRequest(url: "friend/accept_request", body: body, type: .post)
        }
    }
}
