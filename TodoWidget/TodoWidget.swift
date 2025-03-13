//
//  TodoWidget.swift
//  TodoWidget
//
//  Created by Nikita Sheludko on 13.03.25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TodosEntry {
        TodosEntry(date: Date(), todos: ["Go to gym", "Do a homework"])
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TodosEntry {
        TodosEntry(date: Date(), todos: ["Go to gym", "Do a homework"])
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TodosEntry> {
        var entries: [TodosEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 24 {
            let todos = ["Go to gym", "Do a homework"]
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TodosEntry(date: entryDate, todos: todos)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct TodosEntry: TimelineEntry {
    var date: Date
    
    let todos: [String]
    let configuration = ConfigurationAppIntent()
}

struct TodoWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            HStack {
                Text("Overview")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            Divider()
                .padding(.trailing, 25)
                .padding(.bottom, 5)
            
            VStack (alignment: .leading, spacing: 5) {
                Text("Do a homework for today")
                Text("Write an essay")
                Text("Shopping!")
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(.top, 10)
    }
}

struct TodoWidget: Widget {
    let kind: String = "TodoWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TodoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

//#Preview(as: .systemSmall) {
//    TodoWidget()
//} timeline: {
//    TodosEntry(date: .now, configuration: .smiley)
//    TodosEntry(date: .now, configuration: .starEyes)
//}
