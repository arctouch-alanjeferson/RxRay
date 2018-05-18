//
//  ViewController.swift
//  RxRay
//
//  Created by Alan Jeferson on 14/05/18.
//  Copyright © 2018 Alan Jeferson. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButton()
//        Chapter2.main()
//        Chapter3.main()
//        Chapter5.main()
//        Chapter7.main()
        Chapter9.main()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initButton() {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let openStr = NSLocalizedString("open", comment: "")
        button.setTitle(openStr, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        button.rx.tap.asObservable().bind { [weak self] in
            self?.presentSecondController()
        }.disposed(by: bag)
        
    }
    
    private func presentSecondController() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "SecondViewController")
        present(controller!, animated: true, completion: nil)
    }


}

