//
//  TeamMember.swift
//  college-ios-app
//

import SwiftUI

struct TeamMember: Identifiable {
    let name: String
    let role: String
    let github: URL
    let telegram: URL
    let avatar: ImageResource
    let backdrop: ImageResource
    let isWideShot: Bool

    var id: String { name }
}

extension TeamMember {
    static let team: [TeamMember] = [
        TeamMember(
            name: "Иван Коломацкий",
            role: "iOS-разработчик",
            github: URL(string: "https://github.com/anton1ks96")!,
            telegram: URL(string: "https://t.me/IKolomatskii")!,
            avatar: .avatarIvan,
            backdrop: .backdropIvan,
            isWideShot: true
        ),
        TeamMember(
            name: "Артём Джапаридзе",
            role: "Android-разработчик",
            github: URL(string: "https://github.com/airsss993")!,
            telegram: URL(string: "https://t.me/airsss993")!,
            avatar: .avatarArtem,
            backdrop: .backdropArtem,
            isWideShot: false
        )
    ]
}
