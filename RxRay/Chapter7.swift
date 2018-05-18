//
//  Chapter7.swift
//  RxRay
//
//  Created by Alan Jeferson on 17/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

class Chapter7 {
    
    class Student {
        
        let score: BehaviorSubject<Int>
        
        init(score: BehaviorSubject<Int>) {
            self.score = score
        }
        
    }
    
    static func main() {
        
        example(of: "flatMap") {
            
            let bag = DisposeBag()
            
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            student
                .flatMap {
                    $0.score
                }
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: bag)
            
            student.onNext(ryan)
            student.onNext(charlotte)
            ryan.score.onNext(95) // Cool
            charlotte.score.onNext(100)
            
        }
        
        example(of: "flatMapLatest") {
            
            let bag = DisposeBag()
            
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            student
                .flatMapLatest {
                    $0.score
                }
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: bag)
            
            student.onNext(ryan)
            student.onNext(charlotte)
            ryan.score.onNext(95) // Cool
            charlotte.score.onNext(100)
            
        }
        
        example(of: "materialize and dematerialize") {
            
            enum MyError: Error {
                case anError
            }
            
            let disposeBag = DisposeBag()
            
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            let studentScore = student
                .flatMapLatest{
                    $0.score.materialize()
            }
            
            studentScore
                .filter {
                    guard $0.error == nil else {
                        print($0.error!)
                        return false
                    }
                    return true
                }
                .dematerialize()
                .subscribe(onNext: {
                    print($0)
                }, onError: {
                    print("Error flatMapLatest: \($0)")
                })
                .disposed(by: disposeBag)
            
            student.onNext(ryan)
            ryan.score.onNext(85)
            ryan.score.onError(MyError.anError)
            ryan.score.onNext(90)
            student.onNext(charlotte)
            
        }
        
        example(of: "Challenge 1") {
            let disposeBag = DisposeBag()
            
            let contacts = [
                "603-555-1212": "Florent",
                "212-555-1212": "Junior",
                "408-555-1212": "Marin",
                "617-555-1212": "Scott"
            ]
            
            let convert: (String) -> UInt? = { value in
                if let number = UInt(value),
                    number < 10 {
                    return number
                }
                
                let keyMap: [String: UInt] = [
                    "abc": 2, "def": 3, "ghi": 4,
                    "jkl": 5, "mno": 6, "pqrs": 7,
                    "tuv": 8, "wxyz": 9
                ]
                
                let converted = keyMap
                    .filter { $0.key.contains(value.lowercased()) }
                    .map { $0.value }
                    .first
                
                return converted
            }
            
            let format: ([UInt]) -> String = {
                var phone = $0.map(String.init).joined()
                
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
            
            let dial: (String) -> String = {
                if let contact = contacts[$0] {
                    return "Dialing \(contact) (\($0))..."
                } else {
                    return "Contact not found"
                }
            }
            
            let input = Variable<String>("")
            
            // Add your code here
            input
                .asObservable()
                .map(convert)
                .unwrap()
                .skipWhile { $0 == 0 }
                .take(10)
                .toArray()
                .map(format)
                .map(dial)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            
            input.value = ""
            input.value = "0"
            input.value = "408"
            
            input.value = "6"
            input.value = ""
            input.value = "0"
            input.value = "3"
            
            "JKL1A1B".forEach {
                input.value = "\($0)"
            }
            
            input.value = "9"
            
            
        }
        
        example(of: "empty") {
            
            let obs1 = Observable.of(1, 2, 3)
            let obs2 = Observable.of(4, 5, 6, 7, 8)
            
            //            Observable.of(obs1, obs2)
            //                .flatMap { $0 }
            //                .subscribe(onNext: {
            //                    print($0)
            //                })
            
            Observable.of(1, 2, nil, 3)
                .flatMap { $0 == nil ? Observable.empty() : Observable.just($0!) }
                .subscribe(onNext: {
                    print($0)
                })
            
        }
        
    }
    
}
