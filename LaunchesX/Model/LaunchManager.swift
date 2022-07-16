//
//  LaunchManager.swift
//  LaunchesX
//
//  Created by Denys Shkola on 16.07.2022.
//

import Foundation
import Alamofire

class LaunchManager {
    
    var launches: [Launch]?
    var sortOption: SortOption?
    
    func getSortedLaunches() -> [Launch] {
        return sortLaunches(launches ?? [], by: sortOption)
    }
    func setLaunches(_ new: [Launch]) {
        launches = new
    }
    func getSortOption() -> SortOption {
        return sortOption ?? .dataAscending
    }
    func setSortOption(_ new: SortOption) {
        sortOption = new
    }
    
    
    func sortLaunches(_  launches: [Launch], by sortOption: SortOption?) -> [Launch] {
        var result = [Launch]()
        
        if let option = sortOption {
            switch option {
            case .descending:
                result = launches.sorted { $0.name > $1.name }
            case .ascending:
                result = launches.sorted { $0.name < $1.name }
            case .dataAscending:
                result = launches.sorted {
                    if let first = $0.date_local?.getDate(), let second = $1.date_local?.getDate() {
                        return first < second
                    } else {
                        if $0.date_local?.getDate() == nil && $1.date_local?.getDate() != nil {
                            return false
                        } else if $0.date_local?.getDate() != nil && $1.date_local?.getDate() == nil {
                            return true
                        } else {
                            return true
                        }
                    }
                }
            case .dataDescending:
                result = launches.sorted {
                    if let first = $0.date_local?.getDate(), let second = $1.date_local?.getDate() {
                        return first > second
                    } else {
                        if $0.date_local?.getDate() == nil && $1.date_local?.getDate() != nil {
                            return false
                        } else if $0.date_local?.getDate() != nil && $1.date_local?.getDate() == nil {
                            return true
                        } else {
                            return true
                        }
                    }
                }
            }
        }
        return result
    }
    
}
