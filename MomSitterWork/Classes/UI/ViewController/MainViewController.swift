//
//  MainViewController.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/17.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//


import UIKit

/**
* MainViewController
*/
class MainViewController: UIViewController {
    @IBOutlet var tabbarView: TabbarView!
    
    lazy var tabbarItems: [TabbarModel] = {
        let tabItem1 = TabbarModel.init(index: 0, title: "API")
        let tabItem2 = TabbarModel.init(index: 1, title: "Local")
        return [tabItem1, tabItem2]
    }()
    
    private var pageViewController: SearchPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initiailze()
    }

    private func initiailze() {
        setTableView()
    }
    
    private func setTableView() {
        tabbarView.tabbarDataSource = self
        tabbarView.tabbarDataDelegate = self
        tabbarView.reloadData()
        tabbarView.reuseIdentifier = SearchTabbarItemCell.itemIdentifier
        tabbarView.register(UINib.init(nibName: "SearchTabbarItemCell", bundle: nil), forCellWithReuseIdentifier: SearchTabbarItemCell.itemIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier.isEqual("PageVCEmbed")  {
            pageViewController = (segue.destination as! SearchPageViewController)
            pageViewController.searchPageVCDelegate = self
        }
    }
}

extension MainViewController: TabbarViewDataSource {
    func numberOfItem() -> Int {
        return tabbarItems.count
    }
    
    func itemForIndex(index: Int) -> TabbarModel {
        return tabbarItems[index]
    }
}

extension MainViewController: TabbarViewDataDelegate {
    func tabbarView(_ tabbarView: TabbarView, didSelectedItem item: Int) {
        pageViewController.moveViewControllerWithIndex(item)
    }
}

extension MainViewController: SearchPageViewControllerDelegate {
    func SearchPageViewController(_ viewController: SearchPageViewController, didFinishAnimating finished: Bool, moveIndex index: Int) {
        tabbarView.selectItemWithReloadData(index)
    }
}
