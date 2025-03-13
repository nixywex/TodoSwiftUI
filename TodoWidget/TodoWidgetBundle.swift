//
//  TodoWidgetBundle.swift
//  TodoWidget
//
//  Created by Nikita Sheludko on 13.03.25.
//

import WidgetKit
import SwiftUI

@main
struct TodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoWidget()
        TodoWidgetControl()
        TodoWidgetLiveActivity()
    }
}
