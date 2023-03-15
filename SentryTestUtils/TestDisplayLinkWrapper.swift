import Foundation

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
public class TestDisplayLinkWrapper: SentryDisplayLinkWrapper {
    
    public var target: AnyObject!
    public var selector: Selector!
    var internalTimestamp = 0.0
    var internalActualFrameRate = 60.0
    let frozenFrameThreshold = 0.7
    
    var frameDuration: Double {
        return 1.0 / internalActualFrameRate
    }
    
    private var slowFrameThreshold: CFTimeInterval {
        return 1 / (Double(internalActualFrameRate) - 1.0)
    }
    
    public override func link(withTarget target: Any, selector sel: Selector) {
        self.target = target as AnyObject
        self.selector = sel
    }
    
    public func call() {
        _ = target.perform(selector)
    }

    public override var timestamp: CFTimeInterval {
        return internalTimestamp
    }

    public func changeFrameRate(_ newFrameRate: Double) {
        internalActualFrameRate = newFrameRate
    }
    
    public func normalFrame() {
        internalTimestamp += frameDuration
        call()
    }
    
    public func slowFrame() {
        internalTimestamp += slowFrameThreshold + 0.001
        call()
    }
    
    public func almostFrozenFrame() {
        internalTimestamp += frozenFrameThreshold
        call()
    }
    
    public func frozenFrame() {
        internalTimestamp += frozenFrameThreshold + 0.001
        call()
    }
    
    public override var targetTimestamp: CFTimeInterval {
        return internalTimestamp + frameDuration
    }
    
    public override func invalidate() {
        target = nil
        selector = nil
    }
    
    public func givenFrames(_ slow: Int, _ frozen: Int, _ normal: Int) {
        self.call()

        for _ in 0..<slow {
            slowFrame()
        }
        
        for _ in 0..<frozen {
            frozenFrame()
        }

        for _ in 0..<(normal - 1) {
            normalFrame()
        }
    }
}

#endif