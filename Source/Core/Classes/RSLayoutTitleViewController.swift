//
//  RSLayoutTitleViewController.swift
//  Pods
//
//  Created by James Kizer on 7/6/17.
//
//

import UIKit
import ReSwift
import Gloss

class RSLayoutTitleViewController: UIViewController, StoreSubscriber {

    var store: Store<RSState>!
    var layout: RSTitleLayout!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = self.layout.title
        self.imageView.image = self.layout.image
        self.button.setTitle(self.layout.button.title, for: .normal)
        
        self.store.subscribe(self)
        
    }
    
    deinit {
        self.store.unsubscribe(self)
    }
    
    open func newState(state: RSState) {
        self.button.isEnabled = {
            
            guard let predicate = self.layout.button.predicate else {
                return true
            }
            
            return RSActivityManager.evaluatePredicate(predicate: predicate, state: state, context: [:])
            
        }()
    }
    
    open func processAction(action: JSON) {
        RSActionManager.processAction(action: action, context: [:], store: self.store)
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        
        self.layout.button.onTapActions.forEach { self.processAction(action: $0) }
        
    }

}
