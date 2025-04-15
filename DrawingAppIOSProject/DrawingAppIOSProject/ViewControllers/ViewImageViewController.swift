//
//  ViewImageViewController.swift
//  DrawingAppIOSProject
//
//  Created by Jeffrey Pincombe on 2025-03-13.
//

import UIKit

class ViewImageViewController: UIViewController {
    var savedDrawing: UIImage?
    
    @IBOutlet var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = savedDrawing
        // Do any additional setup after loading the view.
    }
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
