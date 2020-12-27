//
//  LocalSearchViewController.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/17.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//


import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources

/**
* LocalSearchViewController
*/
class LocalSearchViewController: UIViewController, ViewModelBindable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var viewModel: APISearchViewModel!

    let dataSource: RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel>(configureCell: {
            (datasource, tableView, indexPath, user) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: GitHubUserTableViewCell.identifier, for: indexPath) as! GitHubUserTableViewCell
            cell.configureCell(user.profileImageURL, favorite: true, name: user.name)
            return cell
        })
        
        ds.titleForHeaderInSection = { item, index in
            //  이전 데이터의 초성과 현재 초성을 비교하여 헤더 타이틀 표시
            let currentSectionModel = item.sectionModels[index]
            if index > 0 {
                let beforeSectionModel = item.sectionModels[index - 1]
                let beforeChoseong = beforeSectionModel.items.first?.name.choseong()
                let currentChoseong = currentSectionModel.items.first?.name.choseong()
                if beforeChoseong != currentChoseong {
                    return currentChoseong
                }
            }else {
                if let name = currentSectionModel.items.first?.name {
                    return name.choseong()
                }
            }
            
            return nil
        }
        
        return ds
    }()

    deinit {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func bindViewModel() {
        //  검색 버튼 클릭
        searchBar.rx.searchButtonClicked
            .do(onNext: { [unowned self] in self.searchBar.resignFirstResponder() })
            .map {
                return self.searchBar.text ?? ""
            }.distinctUntilChanged()
            .bind(to: viewModel.localSearchWord)
            .disposed(by: rx.disposeBag)
        
        //  검색 output
        viewModel.localSearchWord
            .subscribe(onNext: { [unowned self] searchWord in
                self.viewModel.loacalFavoriteUserReload(searchWord)
            })
            .disposed(by: rx.disposeBag)
            
        
        //  테이블 뷰 아이템 바인딩
        viewModel.localSearchUserList
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        //  테이블 뷰 아이템 선택[즐겨찾기 해제]
        Observable.zip(tableView.rx.modelSelected(SearchUserModel.self), tableView.rx.itemSelected)
            .do(onNext:{ [unowned self] (_, indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .bind(to: viewModel.deleteFavoriteUserToLocalDB.inputs)
            .disposed(by: rx.disposeBag)
    }
    
    func initiailze() {
        setTableView()
        registerForKeyboardNotifications()
        searchBar.placeholder = "검색어를 입력하세요."
    }

    private func setTableView() {
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.register(UINib(nibName: GitHubUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: GitHubUserTableViewCell.identifier)
    }
}

extension LocalSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GitHubUserTableViewCell.height
    }
}

extension LocalSearchViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
}


