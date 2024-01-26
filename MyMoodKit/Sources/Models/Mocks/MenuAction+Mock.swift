//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-18.
//

import Foundation

extension MenuAction {
    public static var moodCheckin: MenuAction {
        .init(icon: "face.smiling.inverse", title: "Mood check-in")
    }
    
    public static var secondOptionMock: MenuAction {
        .init(icon: "car", title: "Second option")
    }
}
