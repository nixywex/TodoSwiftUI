//
//  AlertController.swift
//  Todo
//
//  Created by Nikita Sheludko on 29.08.24.
//

import Foundation
import SwiftUI

struct AlertController {
    var alertHeader: String
    var alertText: String
    var alertType: AlertType
    var buttonsActions: [() -> Void]
    var buttonsText: [String]
        
    var buttons: [Button<Text>] {
        switch alertType {
        case .error:
            [Button(action: {
                buttonsActions[0]()
            }, label: {
                Text(buttonsText[0])
            })]
        case .question:
            [
                Button(action: {
                    buttonsActions[0]()
                }, label: {
                    Text(buttonsText[0])
                }),
                Button(action: {
                    buttonsActions[1]()
                }, label: {
                    Text(buttonsText[1])
                        .foregroundStyle(.red)
                })
            ]
        }
    }
}

enum AlertType {
    case error
    case question
}
