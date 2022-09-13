//
//  RegionListViewController.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/30.
//

import UIKit
import CoreData

class RegionListViewController: UIViewController {
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var myRegionTableView: UITableView!
    
    @IBOutlet weak var emptySearchView: UIView!
    @IBOutlet weak var emptySearchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyResultLabel: UILabel!
    
    @IBOutlet weak var dimmingView: UIView!
    
    var cityList = [CityEntity]()
    var myRegionList = [CityEntity]()
    
    var tokens = [NSObjectProtocol]()
    
    @IBAction func dimmingViewHandleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            changeToInitialState()
            searchBar.resignFirstResponder()
        }
    }
    
    deinit {
        for token in tokens {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBySaved()
        changeToInitialState()
        
        var token = NotificationCenter.default.addObserver(forName: ViewController.cityAdded, object: nil, queue: OperationQueue.main) { [weak self] noti in
            self?.searchBySaved()
            self?.myRegionTableView.reloadData()
            
            DispatchQueue.main.async {
                self?.changeToInitialState()
                self?.searchBar.resignFirstResponder()
            }
        }
        tokens.append(token)
        
        token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] noti in
            if let frameValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = frameValue.cgRectValue
                
                self?.emptySearchViewTopConstraint.constant = keyboardFrame.size.height
                
                UIView.animate(withDuration: 0.3) {
                    self?.view.layoutIfNeeded()
                }
            }
        })
        tokens.append(token)
        
        token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] noti in
            self?.emptySearchViewTopConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
        })
        tokens.append(token)
        
        token = NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherForCitiesDidFinishUpdate, object: nil, queue: OperationQueue.main, using: { [weak self] noti in
            self?.myRegionTableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let vc = segue.destination as? ViewController, let indexPath = searchResultTableView.indexPath(for: cell) {
                vc.city = cityList[indexPath.row]
                vc.inAddingState = true
            }
        }
        
        if let cell = sender as? SavedRegionTableViewCell {
            if let vc = segue.destination as? MainViewController, let indexPath = myRegionTableView.indexPath(for: cell) {
                vc.currentViewControllerIndex = indexPath.row
            }
        }
    }
    
    func searchByCityName(_ keyword: String?) {
        guard let keyword = keyword else { return }
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", keyword)
        fetch(predicate: predicate, keyword: keyword, type: "searchByCityName")
        
        handleSearchResultView(keyword: keyword)
    }
    
    func searchBySaved() {
        let predicate = NSPredicate(format: "saved == TRUE")
        fetch(predicate: predicate, keyword: "", type: "searchBySaved")
        WeatherDataSource.shared.fetchWeatherForCities(cityList: myRegionList, completion: nil)
    }
    
    func fetch(predicate: NSPredicate? = nil, keyword: String? = nil, type: String) {
        let request = NSFetchRequest<CityEntity>(entityName: "City")
        
        request.predicate = predicate
        request.fetchBatchSize = 30
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        do {
            if type == "searchByCityName" {
                cityList = try DataManager.shared.mainContext.fetch(request)
            } else if type == "searchBySaved" {
                myRegionList = try DataManager.shared.mainContext.fetch(request)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func handleSearchResultView(keyword: String?) {
        if keyword == "" {
            changeToDimmingSearchState()
        } else if cityList.count != 0 {
            searchResultTableView.reloadData()
            changeToSearchResultState()
        } else {
            emptyResultLabel.text = "'\(keyword ?? "알 수 없음")'에 대한 결과가 없습니다."
            changeToEmptySearchState()
        }
    }
}

extension RegionListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cityList = []
        searchResultTableView.reloadData()
        
        changeToInitialState()
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        changeToDimmingSearchState()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keyword = searchBar.text ?? ""
        searchByCityName(keyword)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
}


extension RegionListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case searchResultTableView:
            return cityList.count
        case myRegionTableView:
            return myRegionList.count
        default:
            fatalError("Unavailable Table")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case searchResultTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
            
            let target = cityList[indexPath.row]
            if let name = target.name {
                cell.textLabel?.text = name
            }
            
            return cell
        case myRegionTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRegionTableViewCell", for: indexPath) as! SavedRegionTableViewCell
            
            let targetCity = myRegionList[indexPath.row]
            
            cell.cityLabel.text = targetCity.name
            cell.timeLabel.text = Date().timeStringWithAmPm
            
            if let targetCityWeather = WeatherDataSource.shared.myWeatherList[targetCity] {
                cell.currentWeatherLabel.text = targetCityWeather.weather.first?.description
                cell.currentTempLabel.text = targetCityWeather.main.temp.temperatureString
                cell.minMaxTempLabel.text = "최고: \(targetCityWeather.main.temp_max) 최저: \(targetCityWeather.main.temp_min)"
            }
            
            return cell
        default:
            fatalError("Unavailable Table")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, completion) in
            DataManager.shared.removeCity(for: self.myRegionList[indexPath.row], in: DataManager.shared.mainContext)
            self.myRegionList.remove(at: indexPath.row)
            self.myRegionTableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        // cell 전체 swipe시 첫번째 action 실행
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

// Functions Regarding Constraints & Styling
extension RegionListViewController {
    func changeToInitialState() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        
        searchBarTopConstraint.isActive = false
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 12)
        searchBarTopConstraint.isActive = true
        
        emptySearchView.alpha = 0.0
        dimmingView.alpha = 0.0
        searchResultTableView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.weatherLabel.alpha = 1.0
            self.moreButton.alpha = 1.0
            self.myRegionTableView.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func changeToEmptySearchState() {
        searchResultTableView.alpha = 0.0
        emptySearchView.alpha = 1.0
    }
    
    func changeToSearchResultState() {
        searchResultTableView.alpha = 1.0
        emptySearchView.alpha = 0.0
    }
    
    func changeToDimmingSearchState() {
        searchBar.setShowsCancelButton(true, animated: true)
        
        searchBarTopConstraint.isActive = false
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        searchBarTopConstraint.isActive = true
        
        weatherLabel.alpha = 0.0
        moreButton.alpha = 0.0
        
        searchResultTableView.alpha = 0.0
        emptySearchView.alpha = 0.0
        myRegionTableView.alpha = 1.0
        dimmingView.alpha = 0.4
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
