//
//  Data.Ext.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import Foundation
typealias JSON = [String: Any]
extension Data {
    func toJSON() -> JSON {
        var json: [String: Any] = [:]
        do {
            if let jsonObj = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? JSON {
                json = jsonObj
            }
        } catch {
            print("JSON casting error")
        }
        return json
    }
}
