//
//  ContentView.swift
//  Particle
//
//  Created by Demian on 06.11.2020.
//  Copyright © 2020 Demian. All rights reserved.
//

import UIKit
import MetalKit
class ContentView: UIViewController{
    var render:Render!
    var mtlView=MTKView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        mtlView.frame = UIScreen.main.nativeBounds
        render = Render(mtlView)
      
        self.view.addSubview(mtlView)
    }
    
}
