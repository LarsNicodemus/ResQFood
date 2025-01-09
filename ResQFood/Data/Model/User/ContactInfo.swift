//
//  ContactInfo.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

struct ContactInfo: Codable {
    var email: String?
    var number: String?
}

extension ContactInfo {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let email = email { dict["email"] = email }
        if let number = number { dict["number"] = number }
        return dict
    }
}
