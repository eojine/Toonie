//
//  LookViewController.swift
//  Toonie
//
//  Created by ebpark on 06/03/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

import UIKit

///Look의 NavigationController
final class LookNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        CommonUtility.shared
            .lookNavigationViewController = self
    }
}

///둘러보기 메인 - 하단 탭 둘러보기로 진입
final class LookViewController: GestureViewController {
    
    // MARK: - Properties
    
    var keywords = [Categorys?]()
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var mainCategoryCollectionView: UICollectionView!
    @IBOutlet private weak var mainCategoryCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewLayout()
        setKeywordValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        CommonUtility.analytics(eventName: "LookViewController",
                                param: ["token": CommonUtility.getUserToken() ?? "toonie"])
    }
    
    // MARK: - Functions
    
    ///컬렉션 뷰 아이템 크기, 위치조정
    func setCollectionViewLayout() {
        mainCategoryCollectionViewFlowLayout.scrollDirection = .vertical
        mainCategoryCollectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.432 ,
                                                               height: (UIScreen.main.bounds.width * 0.432) * 0.96 )
        mainCategoryCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        mainCategoryCollectionViewFlowLayout.minimumLineSpacing = 11.0
        mainCategoryCollectionViewFlowLayout.minimumInteritemSpacing = 1.0
    }
    
    ///keywrods 값들 가져옴
    func setKeywordValue() {
        CategorysService.shared.getCategorys { [weak self] (result) in
            guard let self = self else { return }
            self.keywords = result
            self.reloadKeywordCollectionView()
        }
    }
    
    func reloadKeywordCollectionView() {
        DispatchQueue.main.async {
            self.mainCategoryCollectionView.reloadData()
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension LookViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "LookCell",
                                 for: indexPath) as? LookCell
            else { return UICollectionViewCell() }
        
        
        if let keywordName = keywords[indexPath.row]?.name {
            let image: UIImage? = UIImage.init(named: tagImage(name: keywordName,
                                                               storyboardName: "Look"))
            cell.setBackgroundImageView(image: image)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Look", bundle: nil)
        guard let viewController = storyboard
            .instantiateViewController(withIdentifier: "LookDetailViewController") as? LookDetailViewController
            else {
                return
        }
        
        if let keywordName = keywords[indexPath.row] {
            viewController.selectedCategory = keywordName
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension LookViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        //대분류 카테고리 갯수는 우선 고정.
        return keywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind,
                                              withReuseIdentifier: "HeaderCell",
                                              for: indexPath) 
        return header
    }
}
