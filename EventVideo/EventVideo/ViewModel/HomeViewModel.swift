//
//  HomeViewModel.swift
//  EventVideo
//
//  Created by JayR Atamosa on 1/2/25.
//

import Foundation

class HomeViewModel {
    private var tapCount = 0
    var onTapCountReached: (() -> Void)?
    
    func incrementTapCount() {
        tapCount += 1
        if tapCount == 3 {
            tapCount = 0
            onTapCountReached?()
        }
    }
}
