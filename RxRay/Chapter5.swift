//
//  Chapter5.swift
//  RxRay
//
//  Created by Alan Jeferson on 16/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import Foundation
import RxSwift

class Chapter5 {
    
    static func main() {
        
        // Turns into a completable
        example(of: "Ignore Elements") {
            
            let strikes = PublishSubject<String>()
            let bag = DisposeBag()
            
            strikes
                .ignoreElements()
                .subscribe({ _ in
                    print("You're out")
                })
                .disposed(by: bag)
            
            strikes.onNext("X")
            strikes.onCompleted()
            
        }
        
        example(of: "elementAt") {
            
            let strikes = PublishSubject<Int>()
            let bag = DisposeBag()
            
            strikes
                .elementAt(2)
                .subscribe(onNext: { elem in
                    print("You're out: \(elem)")
                }, onCompleted: {
                    print("Completed")
                })
                .disposed(by: bag)
            
            strikes.onNext(0)
            strikes.onNext(1)
            strikes.onNext(2)
            strikes.onNext(3)
            
        }
        
        example(of: "skipUntil") {
            
            let strikes = PublishSubject<Int>()
            let trigger = PublishSubject<Int>()
            let bag = DisposeBag()
            
            strikes
                .skipUntil(trigger.asObservable())
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: bag)
            
            strikes.onNext(1)
            strikes.onNext(2)
            trigger.onNext(-1)
            strikes.onNext(3)
            
        }
        
        example(of: "takeWhile") {
            
            let bag = DisposeBag()
            
            Observable.of(-1, -2, -3, 0, 1, 2, 3)
                .enumerated()
                .takeWhile { $1 % 2 == 0 && $0 < 3 }
                .map { $1 }
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: bag)
            
        }
        
        example(of: "distinctUntilChange") {
            
            let bag = DisposeBag()
            
            Observable.of(1, 1, 1, 2, 2, 3)
                .distinctUntilChanged()
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: bag)
            
        }
        
        example(of: "Challenge 1") {
            
            let disposeBag = DisposeBag()
            
            let contacts = [
                "603-555-1212": "Florent",
                "212-555-1212": "Junior",
                "408-555-1212": "Marin",
                "617-555-1212": "Scott"
            ]
            
            func phoneNumber(from inputs: [Int]) -> String {
                var phone = inputs.map(String.init).joined()
                
                phone.insert("-", at: phone.index(
                    phone.startIndex,
                    offsetBy: 3)
                )
                
                phone.insert("-", at: phone.index(
                    phone.startIndex,
                    offsetBy: 7)
                )
                
                return phone
            }
            
            let input = PublishSubject<Int>()
            
            // Add your code here
            input
                .asObservable()
                .skipWhile { $0 == 0 }
                .filter { $0 < 10 }
                .take(10)
                .toArray()
                .subscribe(onNext: { numbers in
                    let phone = phoneNumber(from: numbers)
                    if let contact = contacts[phone] {
                        print("Dialing \(contact) (\(phone))...")
                    } else {
                        print("Contact not found")
                    }
                })
                .disposed(by: disposeBag)
            
            input.onNext(0)
            input.onNext(603)
            
            input.onNext(2)
            input.onNext(1)
            
            // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
            input.onNext(2)
            
            "5551212".forEach {
                if let number = (Int("\($0)")) {
                    input.onNext(number)
                }
            }
            
            input.onNext(9)
            
        }
        
        example(of: "toArray") {
            
            let replay = ReplaySubject<String>.create(bufferSize: 3)
            let bag = DisposeBag()
            
            replay.onNext("A")
            replay.onNext("B")
            replay.onNext("C")
            
            replay
                .asObservable()
                .take(2)
                .toArray()
                .subscribe(onNext: {
                    print($0)
                }, onError: {
                    print("Error: \($0)")
                })
                .disposed(by: bag)
            
//            replay.onCompleted()
            replay.onError(RxError.unknown)
            
            
        }
        
    }
    
}
