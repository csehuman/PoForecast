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
    
    var topInset = CGFloat(0.0)
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.backgroundColor = .clear
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        
//        let location = CLLocation(latitude: 37.489206, longitude: 127.02761)
//        WeatherDataSource.shared.fetch(location: location) {
//            self.listTableView.reloadData()
//        }
        
        
        LocationManager.shared.updateLocation()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherInfoDidUpdate, object: nil, queue: OperationQueue.main) { noti in
            self.listTableView.reloadData()
            self.locationLabel.text = LocationManager.shared.currentLocationTitle
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
            
            if let weather = WeatherDataSource.shared.summary?.weather.first, let main = WeatherDataSource.shared.summary?.main {
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
