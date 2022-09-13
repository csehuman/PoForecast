//
//  DataManager+FIrstLaunch.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/30.
//

import Foundation
import CoreData

extension DataManager {
    @available(iOS 14.0, *)
    private func newBatchInsert(with cities: [CityJSON]) -> NSBatchInsertRequest {
        var index = 0
        let total = cities.count
        
        let batchInsert = NSBatchInsertRequest(entity: CityEntity.entity()) { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
            
            if let city = managedObject as? CityEntity {
                let data = cities[index]
                city.id = Int64(data.id)
                city.name = data.name
                city.code = data.country
                city.latitude = data.coord.lat
                city.longitude = data.coord.lon
            }
            
            index += 1
            return false
        }
        
        return batchInsert
    }
    
    @available(iOS 14.0, *)
    func setUpCityList() {
        let cities = CityJSON.parsed()
        
        guard !cities.isEmpty else { return }
        
        DataManager.shared.persistentContainer.performBackgroundTask { context in
            let batchInsert = self.newBatchInsert(with: cities)
            
            do {
                try context.execute(batchInsert)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
