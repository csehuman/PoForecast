//
//  RawData.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/30.
//

import Foundation
import FileProvider

struct CityJSON: Codable {
    let name: String
    let id: Int
    let country: String
    
    let coord: Coordinate
    
    struct Coordinate: Codable {
        let lat: Double
        let lon: Double
    }
    
    static func parsed() -> [CityJSON] {
        do {
            guard let fileUrl = Bundle.main.url(forResource: "citylist", withExtension: "json") else {
                fatalError("Cannot find file resources")
            }
            
            guard let data = try? Data(contentsOf: fileUrl) else {
                fatalError()
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode([CityJSON].self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
