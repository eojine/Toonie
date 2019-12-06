//
//  KeywordSelectViewController.swift
//  Toonie
//
//  Created by ebpark on 26/02/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

import UIKit
import KTCenterFlowLayout

final class KeywordSelectViewController: GestureViewController {

    // MARK: - IBOutlet

    @IBOutlet weak var bigTitleLabel: UILabel!
    @IBOutlet weak var keywordCollecionView: UICollectionView!
    @IBOutlet weak var keywordFlowLayout: KTCenterFlowLayout!
    @IBOutlet weak var keywordCountLabel: UILabel!
    @IBOutlet weak var mainMoveButton: UIButton!

    // MARK: - Properties

    private var layoutMode: Bool = false
    var selectingCategoryArray = [String]() // 선택할 카테고리가 들어갈 배열
    
    var categorys = [Categorys]()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUserToken()
        
        if layoutMode == false {
            bigTitleLabel.text = "관심 있는 키워드를\n3개 이상 선택해주세요."
            mainMoveButton.setTitle("시작하기", for: .normal)
        } else {
            bigTitleLabel.text = "관심 있는 키워드를\n편집해주세요."
            mainMoveButton.setTitle("완료", for: .normal)
            print("내 서재에서 진입")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setKeywordValue()
        
        CommonUtility.analytics(eventName: "KeywordViewController",
                                param: ["token": CommonUtility.getUserToken() ?? "toonie"])
    }

    // MARK: - IBAction

    ///시작하기 버튼-메인으로 이동
    @IBAction func startButtonDidTap(_ sender: UIButton) {
        print("선택한 카테고리 \(selectingCategoryArray)")
        //        // 누르면
        //        postMyCategorys
        MyCategorysService.shared.postMyCategorys(params: selectingCategoryArray) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RootViewController")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }

    // MARK: - Function

    ///keywordFlowLayout 프로퍼티 설정
    func setKeywordFlowLayout() {
        keywordFlowLayout.minimumInteritemSpacing = 10
        keywordFlowLayout.minimumLineSpacing = 20 * CommonUtility.getDeviceRatioHieght()     //라인 사이의 최소간격
        keywordFlowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        keywordFlowLayout.estimatedItemSize = CGSize.init(width: 95, height: 50)
    }
    
    ///키워드 선택할때마다 카운트레이블, 버튼 리로드
    func reloadKeywordView() {
        keywordCountLabel.text = "\(selectingCategoryArray.count)개"
        
        if 3 <= selectingCategoryArray.count {
            //버튼상태 바꿈
            mainMoveButton.isEnabled = true
            mainMoveButton.backgroundColor = UIColor.clear // 그라디언트 소스코드로 적용해야함.
        } else {
            mainMoveButton.isEnabled = false
            mainMoveButton.backgroundColor = UIColor.init(named: "disabledButton")
            // color disableButton 오류
        }
    }
    
    func setLayoutMode(bool: Bool) {
        layoutMode = bool
    }
    
    ///keywords 값들 가져옴
    func setKeywordValue() {
        CategorysService.shared.getCategorys { [weak self] (result) in
            guard let self = self else { return }
            self.categorys = result 
            self.reloadKeywordCollectionView()
        }
    }
    
    func reloadKeywordCollectionView() {
        DispatchQueue.main.async {
            self.keywordCollecionView.reloadData()
        }
    }
    
    ///기기에 UserToken값 없다면 서버에서 받아옴
    func setUserToken() {
        if CommonUtility.getUserToken() == nil {
            TokenService.shared.getToken { result in
                UserDefaults.standard.set(result, forKey: "token")
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension KeywordSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "KeywordCell",
                                 for: indexPath) as? KeywordCell
            else {
                return UICollectionViewCell()
        }
        
        cell.titleLabel.text = categorys[indexPath.row].name
        
        cell.cellStatus = false
        //
        //        //사용자가 선택한 키워드는 활성화처리
        //        for categorySelect in categorySelectArray
        //            where categorys[indexPath.item] == categorySelect {
        //                cell.cellStatus = true
        //        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension KeywordSelectViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let category = categorys[indexPath.item].name{
            let width = Int(category.widthWithConstrainedHeight(height: 49,
                                                                font: UIFont.systemFont(ofSize: 20)))
            return CGSize(width: width + 20, height: 50)
        }

        return CGSize(width: 20, height: 50)

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? KeywordCell {
            cell.cellStatus = !cell.cellStatus

            //선택한 키워드 추가 및 삭제
            if cell.cellStatus == true {
                self.selectingCategoryArray.append(self.categorys[indexPath.item].name ?? "")
            } else {
                let findIndex = self.selectingCategoryArray.firstIndex(of: cell.titleLabel.text ?? "")

                if let index = findIndex {
                    self.selectingCategoryArray.remove(at: index)
                }
            }

            //카운트레이블, 버튼 리로드
            self.reloadKeywordView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension KeywordSelectViewController: UICollectionViewDelegateFlowLayout {
    private func collectionView(collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if let category = categorys[indexPath.item].name{
            let width = Int(category.widthWithConstrainedHeight(height: 49,
                                                                font: UIFont.systemFont(ofSize: 20)))
            return CGSize(width: width + 20, height: 50)
        }
        
        return CGSize(width: 20, height: 50)
    }
}
