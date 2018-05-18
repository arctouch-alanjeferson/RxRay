//
//  Chapter2.swift
//  RxRay
//
//  Created by Alan Jeferson on 14/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import Foundation
import RxSwift

struct Chapter2 {
    
    static func main() {
        
        let bag = DisposeBag()
        
        //        var observable = Observable.of(1, 2, 3)
        //        observable.subscribe { event in
        //            print(event)
        //        }
        
        let observable = Observable<Void>.empty()
        observable.subscribe {
            print($0)
        }
        
        //        let never = Observable<Any>.never()
        //        never.subscribe(onNext: { _ in
        //            print("Never gets printed")
        //        }, onError: { _ in
        //            print("Never gets printed")
        //        }, onCompleted: {
        //            print("Never gets printed")
        //        }) {
        //            print("Never gets printed")
        //        }
        
        
        let range = Observable<Int>.range(start: 0, count: 10)
        range.subscribe { event in
            guard let element = event.element else {
                return
            }
            print(element)
        }
        
        //        let sg = SomeGeneric<Int>()
        //        sg.range(start: 0, count: 0)
        
        //        let created = Observable<Int>.create { observer -> Disposable in
        //
        //            observer.onNext(1)
        //            observer.on(.next(2))
        //            observer.on(.completed)
        //            observer.onNext(2)
        //
        //            return Disposables.create()
        //
        //        }
        
        // Factory
        var flip = false
        let factory = Observable<Int>.deferred { () -> Observable<Int> in
            
            flip = !flip
            
            if flip {
                return Observable.of(1, 2, 3)
            } else {
                return Observable.of(4, 5, 6)
            }
            
        }
        
        (0..<2).forEach { i in
            factory.bind(onNext: { i in
                print(i, terminator: "")
            }).disposed(by: bag)
            print()
        }
        
        enum SingleError: Error {
            case odd
        }
        
        //        Single<Int>.create { single -> Disposable in
        //            single(SingleEvent.success(1))
        //            single(.error(SingleError.odd))
        //            return Disposables.create()
        //        }
        
        
        // Do operator
        //        let never = Observable<Int>.never()
        //        never
        //            .do(onNext: { _ in
        //                print("Never has no events do")
        //            }, onError: { _ in
        //                print("Never has no errors")
        //            }, onCompleted: {
        //                print("Never never completes")
        //            }, onSubscribe: {
        //                print("Never will subscribe")
        //            }, onSubscribed: {
        //                print("Never finished subscribing")
        //            }, onDispose: {
        //                print("Never will dipose")
        //            })
        //            .subscribe {
        //                print("Never has no events: \($0.event)")
        //            }
        //            .disposed(by: bag)
        
        Observable<Void>.create { observer -> Disposable in
            print("Inside subscribe")
            observer.onCompleted()
            return Disposables.create()
            }.do(onSubscribe: {
                print("Do will subscribe")
            }, onSubscribed: {
                print("Do did subscribe")
            })
            .subscribe()
            .disposed(by: bag)
        
        // Debug operator
        Observable<Int>.create { observer -> Disposable in
            (0..<3).forEach { observer.onNext($0) }
            return Disposables.create()
            }
            .debug("BM")
            .map { return $0 * -1 }
            .debug("AM")
            .subscribe()
            .disposed(by: bag)
        
    }
    
}

class SomeGeneric<T> {
    
}

extension SomeGeneric where T == Int {
    
    func range(start: T, count: T) {
        print("Ranging..")
    }
    
}
