//
//  pageViewController.swift
//  LIST
//
//  Created by 蔡雨倩 on 21/06/2018.
//  Copyright © 2018 蔡雨倩. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let ref = Database.database().reference()
    var listIDs = [String]()
    let user = LISTUser()
    
    lazy var subviewControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        viewControllers.append(newVc(viewController: "archiveHome", index: -1))
        for index in listIDs.indices {
            viewControllers.append(newVc(viewController: "archiveList", index: index))
            (viewControllers[viewControllers.count - 1] as! ArchiveListViewController).listID = listIDs[index]
        }
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
//        if let firstViewController = subviewControllers.first {
//            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func newVc(viewController: String, index: Int) -> UIViewController {
        if viewController == "archiveList" {
            let archiveListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController
            ) as! ArchiveListViewController
            archiveListVC.listID = listIDs[index]
            return archiveListVC
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController
            )
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = subviewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return subviewControllers.last
        }
        guard subviewControllers.count > previousIndex else {
            return nil
        }
        
        return subviewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = subviewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard subviewControllers.count != nextIndex else {
            return subviewControllers.first
        }
        guard subviewControllers.count > nextIndex else {
            return nil
        }
        return subviewControllers[nextIndex]
    }
}
