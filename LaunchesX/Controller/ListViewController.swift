//
//  ListViewController.swift
//  LaunchesX
//
//  Created by Denys Shkola on 12.07.2022.
//

import UIKit
import Alamofire
import SDWebImage

class ListViewController: UIViewController {
    
    var manager = LaunchManager() // launches must be initialized once after API request
   
    var filteredLaunches = [Launch]() // filteredLaunches changes after changing searchBar text
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Options.plist")
        // Persist data (sortOption) in specific .plist file on device
        // if sortOptions was String, it would be stored using UserDefaults
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: K.cell) // Register nib for custom cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRequest()
        loadOptions()
        
    }
    
    func fetchRequest() {
        
        Alamofire.request(K.url, method: .get).responseJSON() { response in
            
            if response.result.isSuccess {
                if let data = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.manager.setLaunches(try decoder.decode([Launch].self, from: data))
                        self.filteredLaunches = self.manager.getSortedLaunches()
                        
                    } catch {
                        print(error)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
//MARK: - Local Data Persistence methods
    
    func saveOptions() {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(manager.getSortOption())
            try data.write(to: dataFilePath!)
        } catch {
            print(error)
        }
    }
    
    func loadOptions() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            
            let decoder = PropertyListDecoder()
            
            do {
                manager.setSortOption( try decoder.decode(SortOption.self, from: data))
                sortFilteredLaunches()
            } catch {
                print(error)
            }
        }
    }
    
    func sortFilteredLaunches() {
        
        filteredLaunches = manager.sortLaunches(filteredLaunches, by: manager.getSortOption())
        
        tableView.reloadData()
    }
    
//MARK: - ActionSheet
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "Sort table", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let aToz = UIAlertAction(title: "From A To Z", style: .default) {_ in
            self.manager.setSortOption(.ascending)
            self.saveOptions()
            self.sortFilteredLaunches()

        }
        let zToa = UIAlertAction(title: "From Z To A", style: .default) {_ in
            self.manager.setSortOption(.descending)
            self.saveOptions()
            self.sortFilteredLaunches()
            
        }
        let fromOldest = UIAlertAction(title: "From Oldest to Newest", style: .default) {_ in
            self.manager.setSortOption(.dataAscending)
            self.saveOptions()
            self.sortFilteredLaunches()
            
        }
        let fromNewest = UIAlertAction(title: "From Newest to Oldest", style: .default) {_ in
            self.manager.setSortOption(.dataDescending)
            self.saveOptions()
            self.sortFilteredLaunches()
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
                
                ldc.imageArray = self.filteredLaunches[indexPath.row].links.flickr.original as? [String]
                ldc.launchName = self.filteredLaunches[indexPath.row].name
                ldc.details = self.filteredLaunches[indexPath.row].details
                ldc.youtubeURL = self.filteredLaunches[indexPath.row].links.youtube_id
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
        return filteredLaunches.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell, for: indexPath) as! ListCell
        
        cell.nameLabel.text = self.filteredLaunches[indexPath.row].name
        
        if let patch = self.filteredLaunches[indexPath.row].links.patch.small {
            if let url = URL(string: patch) {
                cell.patchImageView.sd_setImage(with: url) // Parse image from URL when creates cell
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = K.dateFormat
        
        if let dateString = filteredLaunches[indexPath.row].date_local, let precision = filteredLaunches[indexPath.row].date_precision {
            
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
        
        if searchText.isEmpty {
            
            filteredLaunches = manager.getSortedLaunches()
        } else {
            
            filteredLaunches = manager.getSortedLaunches().filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
}

//MARK: - Type Extensions

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
                    dateString += "1HY"
                } else {
                    dateString += "2HY"
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
