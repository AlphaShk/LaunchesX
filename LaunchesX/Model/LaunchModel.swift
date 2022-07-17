import Foundation

class LaunchModel {
    
    var launches: [Launch]?
    var sortOption: SortOption?
    var filterString: String?
    
    func getFilteredLaunches() -> [Launch] {
        if let filterString = filterString {
            return launches?.filter { $0.name.lowercased().contains(filterString.lowercased()) } ?? []
        } else {
            return launches ?? []
        }
    }
    
}
