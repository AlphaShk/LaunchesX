import UIKit
import Network
import SDWebImage

class ListViewController: UIViewController {
    
    var manager = LaunchManager()
    var model = LaunchModel()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Options.plist")
        // Persist data (sortOption) in specific .plist file on device
        // if sortOptions was String, it would be better to store it using UserDefaults
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: K.cell) // Register nib for custom cell
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let alert = UIAlertController(title: "Internet Connection", message: "Check your internet connection", preferredStyle: .alert)
        var canPresent = true
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            
            if pathUpdateHandler.status == .satisfied { // Check if user has Internet connection
                
                self.manager.performRequest() { launches in
                    
                    DispatchQueue.main.async { // Perform all UI changes from main thread
                        
                        alert.dismiss(animated: true)
                    }
                    
                    self.model.setLaunches(new: launches)
                    self.loadOptions()
                    self.sortLaunches()
                }
            } else {
                
                DispatchQueue.main.async {
                    
                    if canPresent {
                        
                        self.present(alert, animated: true)
                        canPresent = false // Present alert only once
                    }
                }
            }
        }

        monitor.start(queue: queue)
        
    }
    
    func sortLaunches() {
        
        model.filteredLaunches = manager.sortLaunches(model.filteredLaunches ?? [], by: model.sortOption)
        self.tableView.reloadData()
    }
    
//MARK: - Local Data Persistence methods
    
    func saveOptions() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(model.sortOption)
            try data.write(to: dataFilePath!)
        } catch {
            print(error)
        }
    }
    
    func loadOptions() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            
            let decoder = PropertyListDecoder()
            
            do {
                model.sortOption = try decoder.decode(SortOption.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
//MARK: - ActionSheet
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "Sort table", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let aToz = UIAlertAction(title: "From A To Z", style: .default) {_ in
            
            self.model.sortOption = .ascending
            self.sortLaunches()
            self.saveOptions()
        }
        let zToa = UIAlertAction(title: "From Z To A", style: .default) {_ in
            
            self.model.sortOption = .descending
            self.sortLaunches()
            self.saveOptions()
        }
        let fromOldest = UIAlertAction(title: "From Oldest to Newest", style: .default) {_ in
            
            self.model.sortOption = .dateAscending
            self.sortLaunches()
            self.saveOptions()
        }
        let fromNewest = UIAlertAction(title: "From Newest to Oldest", style: .default) {_ in
            
            self.model.sortOption = .dateDescending
            self.sortLaunches()
            self.saveOptions()
        }
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(aToz)
        actionSheet.addAction(zToa)
        actionSheet.addAction(fromNewest)
        actionSheet.addAction(fromOldest)
        
        self.present(actionSheet, animated: true)
    }
    
   
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.segue {
            
            let ldc = segue.destination as! LaunchDetailController
            
            if let indexPath = tableView.indexPathForSelectedRow { // If some tableView cell was clicked
                
                guard let launches = model.filteredLaunches else { return } // filteredLaunches can't be nil
                
                ldc.imageArray = launches[indexPath.row].links.flickr.original as? [String]
                ldc.launchName = launches[indexPath.row].name
                ldc.details = launches[indexPath.row].details
                ldc.youtubeURL = launches[indexPath.row].links.youtube_id
            }
        }
    }
    
}

//MARK: - TableViewDelegate, TableViewDataSource methods

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.filteredLaunches?.count ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell, for: indexPath) as! ListCell
    
        guard let launches = model.filteredLaunches else { return cell }
        
        cell.nameLabel.text = launches[indexPath.row].name
        
        if let patch = launches[indexPath.row].links.patch.small {
            
            if let url = URL(string: patch) {
                
                cell.patchImageView.sd_setImage(with: url) // Parse image from URL when creates cell
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = K.dateFormat
        
        if let dateString = launches[indexPath.row].date_local, let precision = launches[indexPath.row].date_precision {
            
            let date = formatter.date(from: dateString)
            cell.dateLabel.text = date?.toString(with: precision)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: K.segue, sender: self)
    }
    
}

//MARK: - SearchBarDelegate methods

extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let allSortedLaunches = manager.sortLaunches(model.launches ?? [], by: model.sortOption) // launches array will be used and sorted once in this function
        model.filteredLaunches = manager.filterLaunches(filter: searchText, launches: allSortedLaunches)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
}

//MARK: - Extensions

extension Date {
    
    func toString(with precision: String) -> String { // Specific method to get string from data with some precision
        
        let formatter = DateFormatter()
        var dateString = ""
        
        switch precision {
            
        case "quarter":
            
            formatter.dateFormat = "MM"
            
            if let month = Int(formatter.string(from: self)) {
                if month > 8 && month < 12 {
                    dateString += "Autumn, "
                } else if month > 2 && month < 6{
                    dateString += "Spring, "
                } else if month > 5 && month < 9{
                    dateString += "Summer, "
                } else {
                    dateString += "Winter, "
                }
            }
            
            formatter.dateFormat = "yyyy"
            dateString += formatter.string(from: self)
            
        case "half":
            
            formatter.dateFormat = "MM"
            
            if let month = Int(formatter.string(from: self)) {
                if month <= 6 {
                    dateString += "1HY, "
                } else {
                    dateString += "2HY, "
                }
            }
            
            formatter.dateFormat = "yyyy"
            dateString += formatter.string(from: self)
            
        case "year":
            
            formatter.dateFormat = "yyyy"
            dateString = formatter.string(from: self)
            
        case "month":
            
            formatter.dateFormat = "MMM, yyyy"
            dateString = formatter.string(from: self)
            
        case "day":
            
            formatter.dateFormat = "MMM dd, yyyy"
            dateString = formatter.string(from: self)
            
        case "hour":
            
            formatter.dateFormat = "HH:mm, MMM dd, yyyy"
            dateString = formatter.string(from: self)
            
        default:
            break
        }
        return dateString
    }
}

extension String {
    
    func getDate() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = K.dateFormat
        
        return formatter.date(from: self)
    }
}
