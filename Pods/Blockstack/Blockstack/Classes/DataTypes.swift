//
//  DataTypes.swift
//  Blockstack
//
//  Created by Yukan Liao on 2018-04-12.
//

import Foundation

public struct UserDataToken: Codable {
    let header: Header
    let payload: UserData?
    let signature: String
}

public struct Header: Codable {
    let typ, alg: String?
}

public class UserData: Codable {
    public let jti: String?
    public let iat, exp: Int?
    public let iss: String?
    public var privateKey: String?
    public let publicKeys: [String]?
    public let username, email, coreToken, profileURL, hubURL, version: String?
    public let claim: Profile?
    public var profile: Profile?

    enum CodingKeys: String, CodingKey {
        case jti, iat, exp, iss
        case privateKey = "private_key"
        case publicKeys = "public_keys"
        case profile, username, claim
        case coreToken = "core_token"
        case email
        case profileURL = "profile_url"
        case hubURL = "hubUrl"
        case version
    }
}

public struct Profile: Codable {
    public let type: String?
    public let context: String?
    public let name: String?
    public let description: String?
    public let apps: [String: String]?
    public let image: [Content]?
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case context = "@context"
        case name, description, apps, image
    }
}

public struct Content: Codable {
    public let type: String?
    public let name: String?
    public let contentUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case name, contentUrl
    }
}

// Special structs to handle profile.json tokens - which returns iat and exp in datetime string format instead of timestamp

public struct ProfileTokenFile: Codable {
    public let token: String?
    public let decodedToken: ProfileToken?
}

public struct ProfileToken: Codable {
    public let header: Header
    public let payload: ProfileTokenPayload?
    public let signature: String
}

public struct ProfileTokenPayload: Codable {
    public let jti: String?
    public let iat, exp: String?
    public let subject: [String: String]?
    public let issuer: [String: String]?
    public let claim: Profile?
}

public struct NameInfo: Codable {
    var address: String
    var blockchain: String
    var expire_block: Int?
    var last_txid: String
    var status: String
    var zonefile: String
    var zonefile_hash: String
}

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
