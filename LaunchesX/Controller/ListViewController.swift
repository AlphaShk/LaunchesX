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
   
    var launches: [Launch]?
    var filteredLaunches = [Launch]()
    
    var sortOption: SortOption?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: K.cell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRequest()
        
    }
    
    func fetchRequest() {
        
        Alamofire.request(K.url, method: .get).responseJSON() { response in
            if response.result.isSuccess {
                if let data = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.launches = try decoder.decode([Launch].self, from: data)
                        self.filteredLaunches = self.launches ?? []
                        
                    } catch {
                        print(error)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    func sortLaunches() {
        if let option = sortOption {
            switch option {
            case .descending:
                filteredLaunches = filteredLaunches.sorted { $0.name > $1.name }
            case .ascending:
                filteredLaunches = filteredLaunches.sorted { $0.name < $1.name }
            case .dataAscending:
                filteredLaunches = filteredLaunches.sorted { ($0.date_local?.getDate())! < ($1.date_local?.getDate())! }
            case .dataDescending:
                filteredLaunches = filteredLaunches.sorted { ($0.date_local?.getDate())! > ($1.date_local?.getDate())! }
            }
        }
        tableView.reloadData()
    }

    @IBAction func edit(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Sort table", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let aToz = UIAlertAction(title: "A-Z", style: .default) {_ in
            self.sortOption = .ascending
            self.sortLaunches()
        }
        let zToa = UIAlertAction(title: "Z-A", style: .default) {_ in
            self.sortOption = .descending
            self.sortLaunches()
        }
        let fromOldest = UIAlertAction(title: "From Oldest to Newest", style: .default) {_ in
            self.sortOption = .dataAscending
            self.sortLaunches()
        }
        let fromNewest = UIAlertAction(title: "From Newest to Oldest", style: .default) {_ in
            self.sortOption = .dataDescending
            self.sortLaunches()
        }
        actionSheet.addAction(cancel)
        actionSheet.addAction(aToz)
        actionSheet.addAction(zToa)
        actionSheet.addAction(fromNewest)
        actionSheet.addAction(fromOldest)
         
        present(actionSheet, animated: true)
    }
    
   
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.segue {
            let ldc = segue.destination as! LaunchDetailController
            if let indexPath = tableView.indexPathForSelectedRow {
                ldc.imageArray = self.filteredLaunches[indexPath.row].links.flickr.original as? [String]
                ldc.launchName = self.filteredLaunches[indexPath.row].name
                ldc.details = self.filteredLaunches[indexPath.row].details
                ldc.youtubeURL = self.filteredLaunches[indexPath.row].links.youtube_id
            }
        }
        
    }
    

}

//MARK: - TableView

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

        if launches != nil {
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLaunches.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell, for: indexPath) as! ListCell
        
        cell.nameLabel.text = self.filteredLaunches[indexPath.row].name
        
        if let patch = self.filteredLaunches[indexPath.row].links.patch.small {
            if let url = URL(string: patch) {
                cell.patchImageView.sd_setImage(with: url)
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

//MARK: - SearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let launches = launches else { return }
        if searchText.isEmpty {
            
            filteredLaunches = launches
        } else {
            
            filteredLaunches = launches.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
}

extension Date {
    
    func toString(with precision: String) -> String {
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
