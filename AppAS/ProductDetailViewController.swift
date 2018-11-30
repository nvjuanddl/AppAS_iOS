//
//  ProductDetailViewController.swift
//  AppAS
//
//  Created by Juan  Delgado Lasso on 30/11/18.
//  Copyright © 2018 Juan Delgado. All rights reserved.
//

import UIKit
import SDWebImage
import SKPhotoBrowser

class ProductDetailViewController: UIViewController, SKPhotoBrowserDelegate {
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    var product : Product?
    var photoData = [URL]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.CreateUI()
    }
    
    private func CreateUI(){
        let url = URL(string: product?.image ?? "")
        imgProduct.sd_setImage(with: url, completed: nil)
        lblName.text = product?.name
        lblDetail.text = product?.detail
    }
    
    
    @IBAction func ActionZoomImgProduct(_ sender: UIButton) {
        let url = URL(string: product?.image ?? "")
        photoData = [url] as! [URL]
        let browser = SKPhotoBrowser(photos: createWebPhotos())
        browser.initializePageIndex(0)
        browser.delegate = self
        present(browser, animated: false, completion: nil)
    }
    
    func createWebPhotos() -> [SKPhotoProtocol] {
        return (0 ..< photoData.count).map { (i: Int) -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImageURL(photoData[i].absoluteString)
            photo.caption = "" // caption[i%10]
            photo.shouldCachePhotoURLImage = true
            return photo
        }
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
