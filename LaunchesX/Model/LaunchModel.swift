import Foundation

class LaunchModel {
    
    var launches: [Launch]?
    var sortOption: SortOption?
    var filteredLaunches: [Launch]?
    
    func setLaunches(new launches: [Launch]) {
        self.launches = launches
        self.filteredLaunches = launches
    }
}
