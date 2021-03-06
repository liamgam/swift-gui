import Foundation
import Dispatch

public class BurstLimiter {

    @usableFromInline internal let minDelay: Double

    @usableFromInline internal var lastInvocationTimestamp: Double = 0

    @usableFromInline internal var delayedWorkItem: DispatchWorkItem? = nil
    
    public init(minDelay: Double) {
        
        self.minDelay = minDelay
    }

    @inlinable public final func limit(_ block: @escaping () -> ()) {

        let currentTimestamp = Date.timeIntervalSinceReferenceDate

        let currentDelay = currentTimestamp - lastInvocationTimestamp

        if currentDelay >= minDelay {

            lastInvocationTimestamp = currentTimestamp

            block()

        } else {
            
            let remainingDelay = minDelay - currentDelay

            if let currentWorkItem = delayedWorkItem {

                currentWorkItem.cancel()
            }

            delayedWorkItem = DispatchWorkItem { [weak self] in

                self?.limit(block)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + remainingDelay, execute: delayedWorkItem!) 
        }
    }
}