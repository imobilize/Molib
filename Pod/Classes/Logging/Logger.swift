
import Foundation

protocol Logger {
    
    func verbose(message: String)
    func debug(message: String)
    func info(message: String)
    func warning(message: String)
    func error(message: String)
    func severe(message: String)
}

struct LoggerImpl: Logger {
    
    let log = XCGLogger.defaultInstance()
    
    init(logLevel: XCGLogger.LogLevel) {
        
        log.setup(logLevel, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: logLevel)
    }
    
    func verbose(message: String) {
        
        log.verbose(message)
    }
    
    func debug(message: String) {
     
        log.debug(message)
    }
    
    func info(message: String) {
        
        log.info(message)
    }
    
    func warning(message: String) {
        
        log.warning(message)
    }
    
    func error(message: String) {
        
        log.error(message)
    }
    
    func severe(message: String) {
        
        log.severe(message)
    }
}


struct LoggerFactory {
    
    static func logger() -> Logger {
        
        return LoggerImpl(logLevel: .Verbose)
    }
}
