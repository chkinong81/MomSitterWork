//
//  APISearchUserViewController.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/17.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//


import UIKit
import RealmSwift
import NSObject_Rx
import RxSwift
import RxCocoa
import Alamofire
import RxDataSources

/**
* APISearchUserViewController
*/
class APISearchUserViewController: UIViewController, ViewModelBindable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var viewModel: APISearchViewModel!
    private var notificationToken: NotificationToken?
    
    let dataSource: RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<SearchUserSectionModel>(configureCell: {
            (datasource, tableView, indexPath, user) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: GitHubUserTableViewCell.identifier, for: indexPath) as! GitHubUserTableViewCell
            cell.configureCell(user.profileImageURL, favorite: user.favorite, name: user.name)
            return cell
        })
        
        return ds
    }()
    
    deinit {
        invalidateToken()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addNotificationToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        invalidateToken()
    }
    
    private func addNotificationToken() {
        notificationToken = viewModel.APISearchUserChangeNotifcationToken { [weak self] (notification, realm) in
            self?.tableView.reloadData()
        }
    }
    
    private func invalidateToken() {
        notificationToken?.invalidate()
    }
  
    func bindViewModel() {
        //  검색 버튼 클릭
        searchBar.rx.searchButtonClicked
            .do(onNext: { [unowned self] in self.searchBar.resignFirstResponder() })
            .map {
                return self.searchBar.text
            }.distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.requestAPISearchUser(text)
            }).disposed(by: rx.disposeBag)
        
        //  테이블 뷰 아이템 바인딩
        viewModel.searchUserList
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        //  테이블 뷰 아이템 셀릭트 이벤트 처리[즐겨찾기 user DB에 저장]
        Observable.zip(tableView.rx.modelSelected(SearchUserModel.self), tableView.rx.itemSelected)
            .do(onNext:{ [unowned self] (_, indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }).bind(to: viewModel.insertUserToLocalDB.inputs)
            .disposed(by: rx.disposeBag)
        
        //  즐겨 찾기한 User Item 즐겨찾기 토글
        viewModel.toggleFavoriteOutput
            .subscribe(onNext: { [unowned self] (favorite, indexPath) in
                if let updateCell = self.tableView.cellForRow(at: indexPath) as? GitHubUserTableViewCell {
                    updateCell.toggleStartIconButton()
                }
            }).disposed(by: rx.disposeBag)
        
        //  검색된 유저 페이징 처리
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [unowned self] _, indexPath in
                self.viewModel.fetchNextPageAPISearchUser(indexPath.row)
            }).disposed(by: rx.disposeBag)
    }
    
    func initiailze() {
        setTableView()
        registerForKeyboardNotifications()
        searchBar.placeholder = "검색어를 입력하세요."
    }

    private func setTableView() {
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.dataSource = nil
        tableView.register(UINib(nibName: GitHubUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: GitHubUserTableViewCell.identifier)
    }
}

extension APISearchUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GitHubUserTableViewCell.height
    }
}

extension APISearchUserViewController {
    private func registerForKeyboardNotifications() {
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
