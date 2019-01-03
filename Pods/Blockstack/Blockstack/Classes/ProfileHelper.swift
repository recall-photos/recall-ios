//
//  Profile.swift
//  Blockstack
//
//  Created by Yukan Liao on 2018-04-11.
//

import Foundation

public class ProfileHelper {
    static func fetch(profileURL: URL, completion: @escaping (Profile?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: profileURL) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching profile")
                completion(nil, error)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let profileResponse = try jsonDecoder.decode([ProfileTokenFile].self, from: data)
                let profile = profileResponse[0].decodedToken?.payload?.claim
                completion(profile, nil)
            } catch {
                completion(nil, error)
            }
            
        }
        task.resume()
    }
    
    static func storeProfile(profileData: UserData) {
        self.clearProfile()
        if let profile = try? PropertyListEncoder().encode(profileData) {
            UserDefaults.standard.set(profile, forKey: BlockstackConstants.ProfileUserDefaultLabel)
        }
    }
    
    static func retrieveProfile() -> UserData? {
        if let data = UserDefaults.standard.value(forKey: BlockstackConstants.ProfileUserDefaultLabel) as? Data {
            return try? PropertyListDecoder().decode(UserData.self, from: data)
        } else {
            return nil
        }
    }
    
    static func clearProfile() {
        UserDefaults.standard.removeObject(forKey: BlockstackConstants.ProfileUserDefaultLabel)
    }

    // TODO: Return errors in completion handler
    static func resolveZoneFileToProfile(zoneFile: String, publicKeyOrAddress: String, completion: @escaping (Profile?) -> ()) {
        // TODO: Support legacy zone files
        guard let zoneFile = BlockstackJS().parseZoneFile(zoneFile: zoneFile),
            var tokenFileUrl = zoneFile.uri.first?["target"] as? String else {
                completion(nil)
                return
        }
        
        // Fix url
        if !tokenFileUrl.starts(with: "http") {
            tokenFileUrl = "https://\(tokenFileUrl)"
        }
        
        guard let url = URL(string: tokenFileUrl) else {
            completion(nil)
            return
        }
        
        ProfileHelper.fetch(profileURL: url) { profile, error in
            guard let profile = profile, error == nil else {
                completion(nil)
                return
            }
            completion(profile)
        }
    }

}
