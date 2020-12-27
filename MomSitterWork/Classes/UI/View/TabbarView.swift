//
//  TabbarView.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/17.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import UIKit

protocol TabbarViewDataSource: NSObject {
    func numberOfItem() -> Int
    func itemForIndex(index: Int) -> TabbarModel
}

protocol TabbarViewDataDelegate: NSObject {
    func tabbarView(_ tabbarView: TabbarView, didSelectedItem item: Int)
}

/**
* TabbarView
*/
class TabbarView: UICollectionView {
    @IBInspectable var reuseIdentifier: String = "cell"
    
    weak var tabbarDataSource: TabbarViewDataSource?
    weak var tabbarDataDelegate: TabbarViewDataDelegate?
    
    var currentIndex: Int = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initiailze()
    }
    
    private func initiailze() {
        setCollectionView()
    }
    
    private func setCollectionView() {
        self.dataSource = self
        self.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.setCollectionViewLayout(layout, animated: true)
    }
    
    public func selectItemWithReloadData(_ selectIndex: Int) {
        currentIndex = selectIndex
        self.reloadData()
    }
    
    private func performDidSelectedItem(_ index: Int) {
        if let dt = tabbarDataDelegate {
            dt.tabbarView(self, didSelectedItem: index)
        }
    }
}

extension TabbarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.frame.size.width * 0.5, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension TabbarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItemWithReloadData(indexPath.item)
        performDidSelectedItem(indexPath.item)
    }
}

extension TabbarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let ds = tabbarDataSource else {
            return 0
        }
        return ds.numberOfItem()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: TabbarItemBaseCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TabbarItemBaseCell
        
        if let ds = tabbarDataSource {
            let item: TabbarModel = ds.itemForIndex(index: indexPath.item)
            cell.configureInfo(item.title, selected: currentIndex == indexPath.item)
        }
        
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

