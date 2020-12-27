//
//  SearchPageViewController.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/17.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import UIKit

protocol SearchPageViewControllerDelegate: NSObject {
    func SearchPageViewController(_ viewController: SearchPageViewController, didFinishAnimating finished: Bool, moveIndex index:Int)
}

/**
* SearchPageViewController
*/
class SearchPageViewController: UIPageViewController {
    weak var searchPageVCDelegate: SearchPageViewControllerDelegate?
    
    lazy var viewControllerList: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let apiStorage = APISearchUserStorage()
        let localStorage = LocalSearchUserStorage()
        let viewModel = APISearchViewModel(apiStorage: apiStorage, localStorage: localStorage)
        var firstVC = storyboard.instantiateViewController(withIdentifier: "APISearchUserVC") as! APISearchUserViewController

        firstVC.bind(viewModel: viewModel)
        
        var secondVC: LocalSearchViewController = storyboard.instantiateViewController(withIdentifier: "LocalSearchUserVC") as! LocalSearchViewController
        secondVC.bind(viewModel: viewModel)
        
        return [firstVC, secondVC]
    }()
    
    private var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initiailze()
    }

    private func initiailze() {
        self.dataSource = self;
        self.delegate = self;
            
        if let firstViewController = viewControllerList.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    public func moveViewControllerWithIndex(_ index: Int) {
        if index >= viewControllerList.count {
            return
        }
        let direction: UIPageViewController.NavigationDirection = (currentPage < index) ? .forward : .reverse
        currentPage = index
        let viewController = viewControllerList[index]
        setViewControllers([viewController], direction: direction, animated: true, completion: nil)
    }
}

extension SearchPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllerList.firstIndex(of: viewController) else {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        
        let moveIndex = index - 1;
        
        return viewControllerList[moveIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllerList.firstIndex(of: viewController) else {
            return nil
        }
            
        if index == viewControllerList.count - 1 {
            return nil
        }
        
        let moveIndex = index + 1;
               
        return viewControllerList[moveIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 0
    }


    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension SearchPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first, let moveIndex = viewControllerList.firstIndex(of: currentVC) {
            currentPage = moveIndex
            
            if let dt = searchPageVCDelegate {
                dt.SearchPageViewController(self, didFinishAnimating: completed, moveIndex: currentPage)
            }
        }
    }
}
