//
//  MainViewController.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/09/02.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var dataSource = [CityEntity]()
    
    var currentViewControllerIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let predicate = NSPredicate(format: "saved == TRUE")
        fetch(predicate: predicate)
        
        configurePageViewController()
    }
    
    func configurePageViewController() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: CustomPageViewController.self)) as? CustomPageViewController else {
            return
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(pageViewController.view)
        
        let views: [String: Any] = ["pageView": pageViewController.view!]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        print("Hi")
        
        guard let startingViewController = viewController(at: currentViewControllerIndex) else {
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true)
    }
    
    func viewController(at index: Int) -> ViewController? {
        if index >= dataSource.count || dataSource.count == 0 {
            return nil
        }
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ViewController.self)) as? ViewController else {
            return nil
        }
        
        viewController.index = index
        viewController.city = dataSource[index]
        print("\(index): \(viewController.city?.name ?? "알 수 없음")")
        
        return viewController
    }
    
    func fetch(predicate: NSPredicate? = nil) {
        let request = NSFetchRequest<CityEntity>(entityName: "City")
        
        request.predicate = predicate
        request.fetchBatchSize = 30
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        do {
            dataSource = try DataManager.shared.mainContext.fetch(request)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension MainViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as? ViewController
        
        guard var currentIndex = viewController?.index else {
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        
        if currentIndex == 0 {
            return nil
        }
        
        currentIndex -= 1
        // currentViewControllerIndex = currentIndex
        
        print("before")
        
        return self.viewController(at: currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as? ViewController
        
        guard var currentIndex = viewController?.index else {
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        
        if currentIndex == dataSource.count-1 {
            return nil
        }
        
        currentIndex += 1
        // currentViewControllerIndex = currentIndex
        
        print("after")
        print(currentViewControllerIndex)
        
        return self.viewController(at: currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print(#function)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print(#function)
    }
}
