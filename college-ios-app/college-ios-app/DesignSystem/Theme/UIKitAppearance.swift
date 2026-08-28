//
//  UIKitAppearance.swift
//  college-ios-app
//

import UIKit

enum UIKitAppearance {
    static func apply() {
        let navigation = UINavigationBarAppearance()
        navigation.configureWithTransparentBackground()
        if let large = UIFont(name: OnestWeight.bold.rawValue, size: 34) {
            navigation.largeTitleTextAttributes = [.font: large]
        }
        if let inline = UIFont(name: OnestWeight.semibold.rawValue, size: 17) {
            navigation.titleTextAttributes = [.font: inline]
        }

        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
        UINavigationBar.appearance().compactAppearance = navigation

        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()
        if let label = UIFont(name: OnestWeight.semibold.rawValue, size: 10) {
            for item in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
                item.normal.titleTextAttributes = [.font: label]
                item.selected.titleTextAttributes = [.font: label]
            }
        }

        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}
