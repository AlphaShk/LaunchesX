import Foundation
import Alamofire

struct LaunchManager {
    
    func performRequest(with url: String = K.url, completion: @escaping ([Launch]) -> Void) {

        Alamofire.request(url, method: .get).responseJSON() { response in
            
            if response.result.isSuccess {
                
                if let data = response.data {
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let launches = try decoder.decode([Launch].self, from: data)
                        completion(launches)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func sortLaunches(_  launches: [Launch], by sortOption: SortOption?) -> [Launch] {
        var result = [Launch]()
        
        if let option = sortOption {
            
            switch option {
                
            case .descending:
                result = launches.sorted { $0.name > $1.name }
                
            case .ascending:
                result = launches.sorted { $0.name < $1.name }
                
            case .dateAscending:
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
                
            case .dateDescending:
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
