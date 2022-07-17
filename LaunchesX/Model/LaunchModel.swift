import Foundation

class LaunchModel {
    
    var launches: [Launch]?
    var sortOption: SortOption?
    var filterString: String?
    
    var filteredLaunches: [Launch] {
        if let string = filterString {
            return launches?.filter { $0.name.lowercased().contains(string.lowercased()) } ?? []
        } else {
            return launches ?? []
        }
    }
}
