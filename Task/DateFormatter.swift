//
//  DateFormatter.swift
//  Task
//
//  Created by Joash Cohen on 16/04/25.
//

import Foundation

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}
