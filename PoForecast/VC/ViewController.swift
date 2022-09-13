//
//  ViewController.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/29.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var locationLabelView: UIView!
    @IBOutlet weak var locationLabelViewTopConstraint: NSLayoutConstraint!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func addCity(_ sender: Any) {
        if let target = city {
            target.saved = true
            DataManager.shared.saveChanges()
        }
        
        NotificationCenter.default.post(name: Self.cityAdded, object: nil)
        dismiss(animated: true)
    }
    
    var city: CityEntity?
    var myCurrentWeather: CurrentWeather?
    var alreadyHaveWeather: Bool = false
    var inAddingState: Bool = false
    
    var index = 0
    var topInset = CGFloat(0.0)
    
    static let cityAdded = Notification.Name(rawValue: "cityAdded")
    
    // view의 배치가 완료된 다음 호출
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if topInset == 0.0 {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            if let cell = listTableView.cellForRow(at: firstIndexPath) {
                topInset = listTableView.frame.height - cell.frame.height
                
                var inset = listTableView.contentInset
                inset.top = topInset
                listTableView.contentInset = inset
            }
            
            listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        initializeView(isAdding: inAddingState)
        
        if let city = city {
            let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
            WeatherDataSource.shared.fetch(location: location) {
                NotificationCenter.default.post(name: WeatherDataSource.weatherInfoDidUpdate, object: nil)
                self.listTableView.reloadData()
            }
            
        } else {
            LocationManager.shared.updateLocation()
        }
        
        NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherInfoDidUpdate, object: nil, queue: OperationQueue.main) { noti in
            if let weather = WeatherDataSource.shared.summary {
                if !self.alreadyHaveWeather {
                    self.myCurrentWeather = weather
                    self.alreadyHaveWeather = true
                }
            }
            
            self.listTableView.reloadData()
            
            
            
            if let city = self.city {
                self.locationLabel.text = city.name ?? "알 수 없음"
            } else {
                self.locationLabel.text = LocationManager.shared.currentLocationTitle
            }
           //LocationManager.shared.currentLocationTitle
            
            UIView.animate(withDuration: 0.3) {
                self.completeAllView(isAdding: self.inAddingState)
            }
        }
    }


}


extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return WeatherDataSource.shared.forecastList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
            
            if let weather = myCurrentWeather?.weather.first, let main = myCurrentWeather?.main {
                cell.weatherImageView.image = UIImage(named: weather.icon)
                cell.statusLabel.text = weather.description
                cell.minMaxLabel.text = "최고 \(main.temp_max.temperatureString)  최소 \(main.temp_min.temperatureString)"
                cell.currentTemperatureLabel.text = "\(main.temp.temperatureString)"
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
        
        let target = WeatherDataSource.shared.forecastList[indexPath.row]
        cell.dateLabel.text = target.date.dateString
        cell.timeLabel.text = target.date.timeString
        cell.weatherImageView.image = UIImage(named: target.icon)
        cell.statusLabel.text = target.weather
        cell.temperatureLabel.text = target.temperature.temperatureString
        
        return cell
    }
}

extension ViewController {
    func initializeView(isAdding: Bool = false) {
        listTableView.alpha = 0.0
        locationLabel.alpha = 0.0
        listButton.alpha = 0.0
        loader.alpha = 1.0
        
        listTableView.backgroundColor = .clear
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        
        navigationBar.alpha = inAddingState ? 1.0 : 0.0
        backgroundImageView.alpha = inAddingState ? 1.0 : 0.0
        
        if !inAddingState {
            locationLabelViewTopConstraint.isActive = false
            locationLabelViewTopConstraint = locationLabelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
            locationLabelViewTopConstraint.isActive = true
        }
    }
    
    func completeAllView(isAdding: Bool = false) {
        listTableView.alpha = 1.0
        locationLabel.alpha = 1.0
        listButton.alpha = isAdding ? 0.0 : 1.0
        loader.stopAnimating()
    }
}
