//
//  OtherExtentions.swift
//  Todo
//
//  Created by Nikita Sheludko on 28.10.24.
//

import Foundation
import FirebaseFirestore

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func prettyDate() -> String {
        self.formatted(.dateTime.day().month())
    }
    
    func prettyDateWithYear() -> String {
        self.formatted(.dateTime.day().month().year())
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map({ document in
            return try document.data(as: T.self, decoder: CodableExtentions.getDecoder())
        })
    }
}

final class CodableExtentions {
    private init() { }

    static func getEncoder() -> Firestore.Encoder {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    static func getDecoder() -> Firestore.Decoder {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
