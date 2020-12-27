//
//  ViewModelBindable.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/19.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import UIKit

protocol ViewModelBindable {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    func initiailze()
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        
        loadViewIfNeeded()
        
        initiailze()
        bindViewModel()
    }
}
