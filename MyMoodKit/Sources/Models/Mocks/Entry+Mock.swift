//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-11.
//

import IdentifiedCollections

extension IdentifiedArray where Element == Entry {
    public static func mockMood() -> IdentifiedArrayOf<Entry> {
        [.mood(.mockGood()), .mood(.mockMeh()), .mood(.mockBad()), .mood(.mockGood()), .mood(.mockMeh()), .mood(.mockBad())]
    }
}

