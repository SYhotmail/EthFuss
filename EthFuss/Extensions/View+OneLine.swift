//
//  View+OneLine.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//

import SwiftUI


extension Text {
    func singleLongLineText() -> some View {
            lineLimit(1)
            .truncationMode(.middle)
    }
}
