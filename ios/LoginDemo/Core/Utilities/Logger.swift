//
//  Logger.swift
//  LoginDemo
//
//  로깅 프로토콜
//

import Foundation

/// 로그 레벨
enum LogLevel: String {
    case debug = "🔍 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
}

/// 로깅 프로토콜
protocol Logger: Sendable {
    /// 디버그 로그
    func debug(
        _ message: String,
        file: String,
        function: String,
        line: Int
    )
    
    /// 정보 로그
    func info(
        _ message: String,
        file: String,
        function: String,
        line: Int
    )
    
    /// 경고 로그
    func warning(
        _ message: String,
        file: String,
        function: String,
        line: Int
    )
    
    /// 에러 로그
    func error(
        _ message: String,
        error: Error?,
        file: String,
        function: String,
        line: Int
    )
}

// MARK: - Default Parameters

extension Logger {
    /// 디버그 로그 (기본 파라미터)
    func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        debug(message, file: file, function: function, line: line)
    }
    
    /// 정보 로그 (기본 파라미터)
    func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        info(message, file: file, function: function, line: line)
    }
    
    /// 경고 로그 (기본 파라미터)
    func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        warning(message, file: file, function: function, line: line)
    }
    
    /// 에러 로그 (기본 파라미터)
    func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.error(message, error: error, file: file, function: function, line: line)
    }
}
