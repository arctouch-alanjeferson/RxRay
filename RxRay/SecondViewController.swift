//
//  SecondViewController.swift
//  RxRay
//
//  Created by Alan Jeferson on 14/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SecondViewController: UIViewController {
    
    @IBOutlet var buttonObserve: UIButton?
    @IBOutlet var buttonDismiss: UIButton?
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupButtons() {
        
        guard let observeSequence = buttonObserve?.rx.tap.asObservable(),
            let dismissSequece = buttonDismiss?.rx.tap.asObservable() else {
                return
        }
        
        observeSequence.bind { [weak self] in self?.didTouchButtonObserve() }.disposed(by: bag)
        dismissSequece.bind { [weak self] in self?.dismiss(animated: true, completion: nil) }.disposed(by: bag)
        
    }
    
    private func didTouchButtonObserve() {
        Observable<Int>.create { observer -> Disposable in
            var count = 0
            while true {
                observer.onNext(count)
                count += 1
                Thread.sleep(forTimeInterval: 1)
            }
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .bind { count in
                print("Count: \(count)")
        }.disposed(by: bag)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
