//
//  Chapter3.swift
//  RxRay
//
//  Created by Alan Jeferson on 14/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Chapter3 {
    
    enum MyError: Error {
        case anError
    }
    
    static func printB<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label, event.element ?? event.error ?? event)
    }
    
    static func main() {
        
        let bag = DisposeBag()
        
        // Only emits to current subscribers
        let subject = PublishSubject<String>()
        subject.onNext("1")
        
        let sub1 = subject.subscribe({ event in
            print("1) \(event.element ?? event.debugDescription)")
        })
        
        subject.on(.next("2"))
        
        subject.subscribe({ event in
            print("2) \(event.element ?? event.debugDescription)")
        }).disposed(by: bag)
        
        subject.onNext("3")
        
        sub1.dispose()
        
        subject.onNext("4")
        
        subject.onCompleted()
        
        // Re-emits the completed event for future subscribers
        subject.subscribe({ event in
            print("3) \(event.element ?? event.debugDescription)")
        }).disposed(by: bag)
        
        
        
        
        // Behavior Subject - reemits the last element (or the initial value)
        
        print("----- BehaviorSubject ------")
        let behavior = BehaviorSubject(value: 1)
        behavior
            .subscribe {
                printB(label: "1)", event: $0)
            }.disposed(by: bag)
        
        
        // Replay Subject - re-emits the n last elements
        print("----- ReplaySubject -----")
        let replay = ReplaySubject<Int>.create(bufferSize: 2)
        
        replay.onNext(1)
        
        replay
            .subscribe {
                printB(label: "R1)", event: $0)
            }
            .disposed(by: bag)
        
        replay.onNext(2)
        replay.onNext(3)
        
        replay.onError(MyError.anError)
//        replay.dispose() // If this is not called, R2 will receive 1, 2 and error (replayingœ)
        
        replay
            .subscribe {
                printB(label: "R2)", event: $0)
            }
            .disposed(by: bag)
        
        
        // Variables
        print("------ Variables ------")
        let variable = Variable(1)
        variable
            .asObservable()
            .subscribe { event in
                printB(label: "Variable", event: event)
        }.disposed(by: bag)
        
        variable.value = 10
        
        let relay = BehaviorRelay(value: 10)
        relay.subscribe {
            printB(label: "Relay", event: $0)
        }.disposed(by: bag)
        
    }
    
}
