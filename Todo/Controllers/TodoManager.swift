//
//  TodoManager.swift
//  Todo
//
//  Created by Nikita Sheludko on 27.10.24.
//

import Foundation
import FirebaseFirestore

struct Todo: Codable {
    let deadline: Date
    let description: String
    let id: String
    let isDone: Bool
    let priority: Int
    let text: String
    let startDate: Date?
    let folderId: String
    let createdAt: Date
    
    var smartPriority: Double {
        var difference = self.deadline.timeIntervalSinceNow
        let coefficient = Double(self.priority) + 2
        
        let compareToToday = Calendar.current.compare(deadline, to: .now, toGranularity: .day)
        
        if compareToToday == .orderedSame {
            difference = abs(difference)
        }
        
        if difference >= 0 {
            return difference / coefficient
        }
        else {
            return difference * coefficient
        }
    }
    
    init(deadline: Date, text: String, folderId: String, priority: Int = 0, description: String = "", startDate: Date? = nil, id: String? = nil, isDone: Bool = false, createdAt: Date = Date()) {
        self.deadline = deadline
        self.description = description
        self.priority = priority
        self.text = text
        self.startDate = startDate
        self.id = id ?? UUID().uuidString
        self.isDone = isDone
        self.folderId = folderId
        self.createdAt = createdAt
    }
    
    enum Priority: Int {
        case low = -1
        case middle = 0
        case high = 1
    }
    
    enum Keys: String, CodingKey {
        case folderId = "folder_id"
        case deadline = "deadline"
        case priority = "priority"
        case text = "text"
        case isDone = "is_done"
        case description = "description"
        case startDate = "start_date"
    }
    
    enum SortType: String, Codable {
        case deadline = "deadline"
        case text = "text"
        case priority = "priority"
        case smart = "smart"
    }
    
    static func validate(text: String, deadline: Date, startDate: Date? = nil, createdAt: Date) throws {
        guard !text.isEmpty else { throw Errors.todoText }
        
        let compareToCreateDate = Calendar.current.compare(deadline, to: createdAt, toGranularity: .day)
        if compareToCreateDate == .orderedAscending { throw Errors.todoDeadline }
        
        if startDate != nil {
            let compareResult = Calendar.current.compare(deadline, to: startDate ?? .now, toGranularity: .day)
            if compareResult != .orderedDescending { throw Errors.todoDeadline }
        }
    }
}
