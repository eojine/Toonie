//
//  MainViewController.swift
//  Toonie
//
//  Created by 이재은 on 24/02/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

import UIKit
import UserNotifications

//Main의 NavigationController
final class MainNavigationController: UINavigationController {
    var rootViewController: UIViewController? {
        return viewControllers.first
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        CommonUtility.shared
            .mainNavigationViewController = self
    }
}

final class MainViewController: GestureViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var feedContainerView: UIView!
    @IBOutlet private weak var lookContainerView: UIView!
    @IBOutlet private weak var communityContainerView: UIView!
    @IBOutlet private weak var myPageContainerView: UIView!
    @IBOutlet private weak var feedButton: UIButton!
    @IBOutlet private weak var lookButton: UIButton!
    @IBOutlet private weak var communityButton: UIButton!
    @IBOutlet private weak var myPageButton: UIButton!
    
    //탭바 이벤트 발생시 수행할 클로저
    var feedDidTapClosure: (() -> Void)?
    var tabDidTapClosure: (() -> Void)?
    
    // MARK: - Property
    private weak var statusButton: UIButton!
    
    private enum TabbarButtonCase {
        case feed, look, community, myPage
        
        var isStatusBool: Bool {
            switch self {
            case .feed:
                return true
            case .look:
                return true
            case .community:
                return true
            case .myPage:
                return true
            }
        }
        
        func showStatusView(view: inout UIView,
                            button: inout UIButton) {
            view.isHidden = !isStatusBool
            button.isSelected =  isStatusBool
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTextCenter()
        tabBarButtonDidTap(feedButton)
        
        //버전 체크
        chkToonieUpdate()
        
        //앱리뷰요청
        CommonUtility.shared.showStoreReview()
        
        setLocalNotification()
        addLocalNotification()
        
        //심사용
        swipeCardPresent { [weak self] in
            self?.popupPresent()
        }
    }
    
    func swipeCardPresent(completion: @escaping () -> Void) {
        let lastCloseTime = UserDefaults.standard.object(forKey: "SwipeCloseTime") as? Date
        
        if CommonUtility.shared
            .checkPassOneDay(by: lastCloseTime,
                             hideDay: 7) == false {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard
                .instantiateViewController(withIdentifier: "SwipeCardViewController")
                as? SwipeCardViewController {
                viewController.modalPresentationStyle = .overCurrentContext
                
                let tagArray = ["가족", "반려동물", "사랑 연애", "심리 감정", "여행", "음식",
                                "자기계발", "자취생활", "직업", "페미니즘", "학교생활", "해외"]
                let index = Int(arc4random_uniform(UInt32((tagArray.count - 1))))
                
                CategoryToonAllListService
                    .shared
                    .getKeywordToonAllList(keyword: tagArray[index],
                                           completion: { [weak self]  (res) in
                                            guard let self = self else { return }
                                            guard let toonData = res else { return }
                                            
                                            var card = [Card]()
                                            //10개제한
                                            var index = 10
                                            for item in toonData {
                                                let cardItem = Card.init(name: item.instaID ?? "instaId",
                                                                         imageUrl: item.instaThumnailUrl ?? "")
                                                card.append(cardItem)
                                                index -= 1
                                                if index == 0 {
                                                    break
                                                }
                                            }
                                            
                                            let cardItem = Card.init(name: "swipeInfo",
                                                                     imageUrl: "swipeInfo")
                                            
                                            card.append(cardItem)
                                            
                                            viewController.card = card
                                            
                                            viewController.dismissClosure = {
                                                self.popupPresent()
                                            }
                                            
                                            CommonUtility.shared
                                                .mainNavigationViewController?
                                                .present(viewController,
                                                         animated: false,
                                                         completion:nil)
                        }, failer: {
                            completion()
                    })
            }
        } else {
            completion()
        }
    }
    
    func popupPresent() {
        //오늘하루 체크
        let lastCloseTime = UserDefaults.standard.object(forKey: "PopupCloseTime") as? Date
        
        if CommonUtility.shared
            .checkPassOneDay(by: lastCloseTime,
                             hideDay: 1) == false {
            
            getCurationTagList { (tagList) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard
                    .instantiateViewController(withIdentifier: "PopupViewController")
                    as? PopupViewController {
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.setTagList(tagList: tagList)
                    
                    CommonUtility.shared
                        .mainNavigationViewController?
                        .present(viewController,
                                 animated: false,
                                 completion:nil)
                }
            }
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MyPage" {
            if let myPageNavigationController = segue.destination as? MyPageNavigationController {
                if let myPageViewController = myPageNavigationController.rootViewController as? MypageViewController {
                    self.tabDidTapClosure = {
                        myPageViewController.viewWillAppear(true)
                    }
                }
            }
        }
    }
    
    // MARK: - Action
    
    @IBAction func tabBarButtonDidTap(_ sender: UIButton) {
        //전에 선택했던 버튼과 같다면 rootViewController로 돌아옴
        if statusButton == sender {
            didTapDoubleButton()
            return
        }
        
        resetSelfView()
        
        switch sender {
        case feedButton:
            TabbarButtonCase.feed.showStatusView(view: &feedContainerView,
                                                 button: &feedButton)
            if let closure = self.feedDidTapClosure {
                closure()
            }
        case lookButton:
            TabbarButtonCase.look.showStatusView(view: &lookContainerView,
                                                 button: &lookButton)
        case communityButton:
            TabbarButtonCase.community.showStatusView(view: &communityContainerView,
                                                      button: &communityButton)
        case myPageButton:
            TabbarButtonCase.myPage.showStatusView(view: &myPageContainerView,
                                                   button: &myPageButton)
            if let closure = self.tabDidTapClosure {
                closure()
            }
        default:
            TabbarButtonCase.feed.showStatusView(view: &feedContainerView,
                                                 button: &feedButton)
        }
        
        statusButton = sender
    }
    
    // MARK: - Function
    ///이전에 선택한 버튼을 또 선택하는 경우 popToRootViewController
    func didTapDoubleButton() {
        switch statusButton {
        case feedButton:
            CommonUtility.shared
                .feedNavigationViewController?
                .popToRootViewController(animated: true)
        case lookButton:
            CommonUtility.shared
                .lookNavigationViewController?
                .popToRootViewController(animated: true)
        case myPageButton:
            CommonUtility.shared
                .myPageNavigationViewController?
                .popToRootViewController(animated: true)
        default:
            CommonUtility.shared
                .feedNavigationViewController?
                .popToRootViewController(animated: true)
        }
    }
    ///뷰 초기화
    func resetSelfView() {
        hideAllContainerView()
        offTabbarButtonState()
    }
    
    ///모든 뷰 컨테이너 숨김
    func hideAllContainerView() {
        feedContainerView.isHidden = true
        lookContainerView.isHidden = true
        communityContainerView.isHidden = true
        myPageContainerView.isHidden = true
    }
    
    ///모든 탭버튼 상태 off
    func offTabbarButtonState() {
        feedButton.isSelected = false
        lookButton.isSelected = false
        communityButton.isSelected = false
        myPageButton.isSelected = false
        
    }
    
    func setButtonTextCenter() {
        feedButton.centerImageAndButton(5, imageOnTop: true)
        lookButton.centerImageAndButton(5, imageOnTop: true)
        communityButton.centerImageAndButton(5, imageOnTop: true)
        myPageButton.centerImageAndButton(5, imageOnTop: true)
    }
    
    ///업데이트 체크
    func chkToonieUpdate() {
        ChkToonieUpdateService.shared.getUpdateInfo { [weak self] result in
            guard let self = self else { return }
            if result.forcedUpdate == true {
                if let forcedVersion = result.forceInfo?.forcedVersion {
                    if CommonUtility.shared
                        .compareToVersion(newVersion: forcedVersion) < 0 {
                        
                        self.chkToonieUpdateAlertShow(message: result
                            .forceInfo?
                            .forcedString ?? "최신 버전이 나왔어요! 업데이트하고 즐거운 투니 되세요!",
                                                      urlString: result
                                                        .forceInfo?
                                                        .forcedMoveUrl ?? "",
                                                      mode: result
                                                        .forceInfo?
                                                        .forcedAlertMode == "oneButton")
                    }
                }
            }
            if result.targetUpdate == true {
                if let targetVersion = result.targetInfo?.targetVersion {
                    if CommonUtility.shared
                        .compareToVersion(newVersion: targetVersion) == 0 {
                        
                        self.chkToonieUpdateAlertShow(message: result
                            .targetInfo?
                            .targetString ?? "최신 버전이 나왔어요! 업데이트하고 즐거운 투니 되세요!",
                                                      urlString: result.targetInfo?.targetMoveUrl ?? "",
                                                      mode: result.targetInfo?.targetAlertMode == "oneButton")
                    }
                }
            }
            
        }
    }
    
    ///모드에 따라 업데이트 알럿을 다르게 띄움
    func chkToonieUpdateAlertShow(message: String,
                                  urlString: String,
                                  mode: Bool) {
        if mode {
            UIAlertController
                .alert(title: nil,
                       message: message,
                       style: .alert)
                .action(title: "업데이트", style: .default) { _ in
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:])
                    }
            }
            .present(to: self)
        } else {
            UIAlertController
                .alert(title: nil,
                       message: message,
                       style: .alert)
                .action(title: "AppStore", style: .default) { _ in
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url, options: [:])
                    }
            }
            .action(title: "취소", style: .default) { _ in
            }
            .present(to: self)
        }
    }
    
    /// 로컬 노티피케이션 설정
    private func setLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert],
                                                                completionHandler: { (_, _) in

        })
        UNUserNotificationCenter.current().delegate = self
    }

    /// 로컬 노티피케이션 추가
    private func addLocalNotification() {
        let content = UNMutableNotificationContent()
        content.body = "오늘은 어떤 툰을 볼까요? 투니가 추천해줄게요!"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: true)
        let request = UNNotificationRequest(identifier: "DailyNoti",
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    //오늘의 추천 태그
    private func getCurationTagList(completion: @escaping ([String]) -> Void) {
        RecommendService.shared.getRecommends {  res in
            let tagCount: UInt32 = UInt32(res.count)
            var randArray = [String]()
            for _ in 0..<4 {
                let randNum: Int = Int(arc4random_uniform(tagCount))
                
                randArray.append(res[randNum])
            }
            
            completion(randArray)
        }
    }

    /// 카드 스와이프 완료 후 알림창
    func swipeCardComplete() {
        UIAlertController
            .alert(title: nil,
                   message: "취향분석에 반영됐어요!\n오늘도 즐거운 투니 되세요!",
                   style: .alert)
            .action(title: "확인", style: .default) { _ in
                UserDefaults.standard.set(Date.init(), forKey: "SwipeCloseTime")
                self.popupPresent()
        }
        .present(to: self)
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        settingsViewController.view.backgroundColor = .white
        self.present(settingsViewController, animated: true, completion: nil)
    }
    
}
