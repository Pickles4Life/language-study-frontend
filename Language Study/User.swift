//
//  User.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/18/22.
//

import Foundation

let TEST_SEARCH_USERS = [
    User(id: UUID(), username: "test9", phoneNumber: "9685326512", streak: 15),
    User(id: UUID(), username: "like", phoneNumber: "8785326521", streak: 2),
    User(id: UUID(), username: "apple", phoneNumber: "7785326533", streak: 4),
    User(id: UUID(), username: "anthony", phoneNumber: "6785326554", streak: 9),
    User(id: UUID(), username: "adrianna", phoneNumber: "5785326554", streak: 8)
]

let TEST_USERS_WITH_RELATIONSHIP = [
    UserWithRelationship(id: TEST_SEARCH_USERS[0].id, username: "test9", phoneNumber: "9685326512", relationship: "Friends"),
    UserWithRelationship(id: TEST_SEARCH_USERS[1].id, username: "like", phoneNumber: "8785326521", relationship: "NotFriends"),
    UserWithRelationship(id: TEST_SEARCH_USERS[2].id, username: "apple", phoneNumber: "7785326533", relationship: "SentFriendRequest"),
    UserWithRelationship(id: TEST_SEARCH_USERS[3].id, username: "anthony", phoneNumber: "6785326554", relationship: "NotFriends"),
    UserWithRelationship(id: TEST_SEARCH_USERS[4].id, username: "adrianna", phoneNumber: "5785326554", relationship: "RecievedFriendRequest")
]


struct User: Codable {
    let id: UUID
    let username: String
    let phoneNumber: String
    let streak: Int
    
    static func fetchMe() async throws -> User {
        if !TEST {
            let data = try await sendRequest(url: "user/me", body: nil, type: .get)
            let jsonDecoder = JSONDecoder()
            let user = try jsonDecoder.decode(User.self, from: data)
            return user
        } else {
            throw ServerError.unauthorized
            /*return User(id: UUID(uuidString: "bf8f4404-c52c-4b1a-865a-3627f115ac87")!, username: "test1", phoneNumber: "9785326542")*/
        }
    }

    static func searchUsers(username: String) async throws -> [User] {
        if !TEST {
            let data = try await sendRequest(url: "user/search", body: ["username": username], type: .post)
            let jsonDecoder = JSONDecoder()
            return try! jsonDecoder.decode([User].self, from: data)
        } else {
            return TEST_SEARCH_USERS.filter {
                $0.username.hasPrefix(username.lowercased())
            }
        }
    }
}

struct UserWithRelationship: Codable {
    let id: UUID
    let username: String
    let phoneNumber: String
    let relationship: String
    
    static func getUser(id: UUID) async throws -> UserWithRelationship {
        if !TEST {
            let data = try await sendRequest(url: "user/get_user/\(id)", body: nil, type: .get)
            let jsonDecoder = JSONDecoder()
            return try! jsonDecoder.decode(UserWithRelationship.self, from: data)
        } else {
            return TEST_USERS_WITH_RELATIONSHIP.first(where: {
                print("\($0.id), \(id)")
                return $0.id == id
            })!
        }
    }
}
