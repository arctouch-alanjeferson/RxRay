//
//  Chapter9.swift
//  RxRay
//
//  Created by Alan Jeferson on 18/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import Foundation
import RxSwift

class Chapter9 {
    
    static func main() {
        
        example(of: "startsWith") {
            
            let bag = DisposeBag()
            
            let observable = Observable.of(2, 3, 4, 5)
            let obs = observable.startWith(0, 1)
            obs.subscribe(onNext: { value in
                print(value)
            })
                .disposed(by: bag)
        }
        
        example(of: "Observable.concat") {
            let bag = DisposeBag()
            let a = Observable.of(1, 2, 3)
            let b = Observable.of(4, 5, 6)
            Observable.concat(a, b)
                .subscribe(onNext: { (value) in
                    print(value)
                })
                .disposed(by: bag)
        }
        
        //        example(of: "share") {
        //
        //            let bag = DisposeBag()
        //
        //            let observable = Observable<Int>.create({ (observer) -> Disposable in
        //                print("Creating observable...")
        ////                observer.onNext(1)
        //                //                observer.onCompleted()
        //
        //                DispatchQueue.global(qos: .background).async {
        //                    var i = 1
        //                    while true {
        //                        observer.onNext(i)
        //                        i += 1
        //                        Thread.sleep(forTimeInterval: 1)
        //                    }
        //                }
        //
        //                return Disposables.create()
        //            })
        //            .share()
        //
        //            observable.subscribe(onNext: { value in
        //                print(value)
        //            })
        ////                .disposed(by: bag)
        //
        //            observable.subscribe(onNext: { value in
        //                print(value)
        //            })
        ////                .disposed(by: bag)
        //
        //        }
        
        
        example(of: "concat") {
            let bag = DisposeBag()
            let a = Observable.of(1, 2, 3)
            let b = Observable.of(4, 5, 6)
            a
                .concat(b)
                .concat(a)
                .printSubscribe(on: bag)
        }
        
        example(of: "concatMap") {
            let bag = DisposeBag()
            let sequences: [String: Observable<Int>] = [
                "odd": Observable.of(1, 3, 5),
                "event": Observable.of(2, 4, 6)
            ]
            let keys = sequences.map { $0.key }
            Observable<String>.from(keys)
                .concatMap { key -> Observable<Int> in return sequences[key]! }
                .printSubscribe(on: bag)
        }
        
        example(of: "merge") {
            let bag = DisposeBag()
            let a = PublishSubject<Int>()
            let b = PublishSubject<Int>()
            let source = Observable.of(a.asObservable(), b.asObservable())
            source
                .merge()
                .printSubscribe(on: bag)
            a.onNext(5)
            b.onNext(1)
            a.onNext(4)
            b.onNext(3)
        }
        
        example(of: "combineLatest") {
            let bag = DisposeBag()
            let a = PublishSubject<Int>()
            let b = PublishSubject<Int>()
            Observable
                .combineLatest(a, b.startWith(0)) { lastLeft, lastRight -> String in
                    return "\(lastLeft) \(lastRight)"
                }
                .printSubscribe(on: bag)
            a.onNext(0)
            a.onNext(1)
            b.onNext(2)
            a.onNext(3)
            b.onNext(4)
        }
        
        example(of: "user choice of date formate") {
            let bag = DisposeBag()
            let formats: Observable<DateFormatter.Style> = Observable.of(.short, .long)
            let date = Observable.of(Date())
            Observable.combineLatest(formats, date, resultSelector: { format, date -> String in
                let formatter = DateFormatter()
                formatter.dateStyle = format
                return formatter.string(from: date)
            })
                .printSubscribe(on: bag)
        }
        
        example(of: "zip") {
            let bag = DisposeBag()
            let a = PublishSubject<Int>()
            let b = PublishSubject<Int>()
            Observable
                .zip(a, b) { lastLeft, lastRight -> String in
                    return "\(lastLeft) \(lastRight)"
                }
                .printSubscribe(on: bag)
            a.onNext(0)
            b.onNext(0)
            a.onNext(1) // Does not print until b sends next value
            //            b.onNext(1)
            // Completes when ONE of the sequences completes
        }
        
        example(of: "withLatestFrom") {
            let bag = DisposeBag()
            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()
            let observable = button.withLatestFrom(textField)
            observable.printSubscribe(on: bag)
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
        }
        
        example(of: "sample") {
            let bag = DisposeBag()
            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()
            let observable = textField.sample(button)
            observable.printSubscribe(on: bag)
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
            // Does not emit Paris twice because textfield did not emit any new value between button emissions
        }
        
        example(of: "withLatestFrom acting like sample") {
            let bag = DisposeBag()
            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()
            let observable = button
                .withLatestFrom(textField)
                .distinctUntilChanged()
            observable.printSubscribe(on: bag)
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
        }
        
        example(of: "amb") {
            // Resolve ambiguity: "who arrives first"
            let bag = DisposeBag()
            let a = PublishSubject<Int>()
            let b = PublishSubject<Int>()
            a.amb(b)
                .printSubscribe(on: bag)
            a.onNext(2)
            b.onNext(1)
            b.onNext(3)
            b.onNext(5)
            a.onNext(4)
            a.onNext(6)
        }
        
        example(of: "switchLatest") {
            // Only emits items from the last observable
            let bag = DisposeBag()
            let a = PublishSubject<Int>()
            let b = PublishSubject<Int>()
            let source = PublishSubject<Observable<Int>>()
            source.switchLatest().printSubscribe(on: bag)
            source.onNext(a)
            source.onNext(b)
            a.onNext(1)
            a.onNext(1)
            b.onNext(2)
        }
        
        example(of: "reduce") {
            // Only reduces when complete
            let bag = DisposeBag()
            let observable = Observable.of(1, 2, 3)
            observable.reduce(0, accumulator: +).printSubscribe(on: bag)
        }
        
        example(of: "scan") {
            // Reduces at every new element
            let bag = DisposeBag()
            let observable = Observable.of(1, 2, 3)
            observable.scan(0, accumulator: +).printSubscribe(on: bag)
        }
        
        example(of: "Challenge 1") {
            let bag = DisposeBag()
            let source = Observable.of(1, 3, 5, 7, 9)
            let observable = source.scan(0, accumulator: +)
            
            Observable.zip(source, observable) { ($0, $1) }
                .subscribe(onNext: { (current, total) in
                    print("\(current) \(total)")
                })
                .disposed(by: bag)
            
            
            source.scan((0, 0)) { (tuple, number) -> (Int, Int) in
                return (number, tuple.1 + number) }
                .map { "\($0.0) \($0.1)" }
                .printSubscribe(on: bag)
            
        }
        
    }
    
}
