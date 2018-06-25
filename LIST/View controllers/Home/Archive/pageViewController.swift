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
    
    lazy var subviewControllers: [UIViewController] = {
        var viewControllers: [UIViewController] = [ArchiveHomePageViewController()]
        for index in listIDs.indices {
            viewControllers.append(ArchiveListViewController())
            (viewControllers[viewControllers.count - 1] as! ArchiveListViewController).listID = listIDs[index]
        }
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        // Do any additional setup after loading the view.
        setViewControllers([subviewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subviewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subviewControllers.index(of: viewController) ?? 0
        if (currentIndex <= 0) {
            return nil
        }
        return subviewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subviewControllers.index(of: viewController) ?? 0
        if (currentIndex >= subviewControllers.count - 1) {
            return nil
        }
        return subviewControllers[currentIndex + 1]
    }
}
