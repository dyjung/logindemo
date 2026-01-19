//
//  OSLogger.swift
//  LoginDemo
//
//  OSLog 기반 로거 구현
//

import Foundation
import OSLog

/// OSLog를 사용하는 로거 구현체
final class OSLogger: Logger {
    // MARK: - Properties
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.example.LoginDemo"
    private let category: String
    
    // MARK: - Initialization
    
    init(category: String = "General") {
        self.category = category
    }
    
    // MARK: - Logger
    
    func debug(_ message: String, file: String, function: String, line: Int) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String, function: String, line: Int) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String, function: String, line: Int) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, error: Error?, file: String, function: String, line: Int) {
        var fullMessage = message
        if let error = error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }
        log(level: .error, message: fullMessage, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(
        level: LogLevel,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(level.rawValue)] [\(fileName):\(line)] \(function) - \(message)"
        
        let logger = os.Logger(subsystem: subsystem, category: category)
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        }
        
        #if DEBUG
        // 디버그 빌드에서는 콘솔에도 출력
        print(logMessage)
        #endif
    }
}
