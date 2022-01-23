//
//  TabBarController.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 18.01.22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController1 = OverviewController()
//        let viewController2 = TopController()
//        let viewController3 = ChartController()
        
        let navigationController1 = UINavigationController(rootViewController: viewController1)
//        let navigationController2 = UINavigationController(rootViewController: viewController2)
//        let navigationController3 = UINavigationController(rootViewController: viewController3)
        
        navigationController1.tabBarItem = UITabBarItem(title: "Overview", image: UIImage(systemName: "house.fill"), tag: 1)
//        navigationController2.tabBarItem = UITabBarItem(title: "Top", image: UIImage(systemName: "chart.bar.fill"), tag: 1)
//        navigationController3.tabBarItem = UITabBarItem(title: "Charts", image: UIImage(systemName: "music.note.list"), tag: 1)
        
        navigationController1.tabBarItem.badgeColor = .greenColor
//        navigationController2.tabBarItem.badgeColor = .acceptColor()
//        navigationController3.tabBarItem.badgeColor = .acceptColor()
        
        tabBar.tintColor = .greenColor
        
        setViewControllers([navigationController1], animated: true)
    }
}
