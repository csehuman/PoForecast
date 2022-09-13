//
//  DataManager+CRUD.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/30.
//

import Foundation
import CoreData

extension DataManager {
    func insertNewCity(from data: CityJSON, in context: NSManagedObjectContext) -> CityEntity? {
        var entity: CityEntity?
        context.performAndWait {
            entity = CityEntity(context: context)
            
            entity?.name = data.name
            entity?.id = Int64(data.id)
            entity?.code = data.country
            entity?.latitude = data.coord.lat
            entity?.longitude = data.coord.lon
        }
        
        return entity
    }
    
    func removeCity(for city: CityEntity, in context: NSManagedObjectContext) {
        context.performAndWait {
            city.saved = false
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
