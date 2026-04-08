//
//  Config.swift
//  Moa
//
//  Created by 정도현 on 4/7/26.
//

import Foundation

public enum Config {
    public enum Keys {
        public enum Plist: String {
            case baseURL = "BASE_URL"
            case kakaoAppKey = "KAKAO_NATIVE_APP_KEY"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
}

extension Config {
    public static func getPropertyValue(_ target: Config.Keys.Plist) -> String {
        guard let key = Config.infoDictionary[target.rawValue] as? String else {
            fatalError("\(target.rawValue) is not set in plist for this configuration.")
        }
        
        return key
    }
}
