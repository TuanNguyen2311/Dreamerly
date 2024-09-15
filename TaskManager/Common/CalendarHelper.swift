//
//  CalendarHelper.swift
//  TaskManager
//
//  Created by Nguyen Anh Tuan on 14/09/2024.
//

import Foundation

class CalendarHelper {
    let calendar = Calendar.current
    
    func plusMonth(date:Date) -> Date {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    func minusMonth(date:Date) -> Date {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    func monthString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    func yearString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    func daysInMonth(date:Date)-> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    func month(date:Date) -> Int {
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    func dayOfMonth(date:Date) -> Int {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    func firstOfMonth(date:Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    func weekDay(date:Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday!-1
    }
    
    func getSelectedIndex(selectedMonth:Date, compareDate:String)->Int {
        let selectedMonthInt = month(date: selectedMonth)
        let projectMonthInt = month(date: compareDate.toDate(Constants.dateFormatted_1) ?? Date())
        let projectDayInt = dayOfMonth(date: compareDate.toDate(Constants.dateFormatted_1) ?? Date())
        if selectedMonthInt != projectMonthInt {
            return -1
        } else {
            let projectDayInt = dayOfMonth(date: compareDate.toDate(Constants.dateFormatted_1) ?? Date())
            
            let firstDayOfMonth = firstOfMonth(date: selectedMonth)
            let startingSpaces = weekDay(date: firstDayOfMonth)
            return startingSpaces + projectDayInt - 1
        }
    }
    
}
