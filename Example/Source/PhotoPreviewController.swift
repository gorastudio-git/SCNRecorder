//
//  PhotoPreviewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 12/03/2019.
//  Copyright © 2020 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

final class PhotoPreviewController: UIViewController {

  let photo: UIImage

  init(photo: UIImage) {
    self.photo = photo
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let imageView = UIImageView(image: photo)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)

    imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .action,
      target: self,
      action: #selector(share(_:))
    )
  }

  @objc func share(_ sender: Any) {
    present(
      UIActivityViewController(activityItems: [photo], applicationActivities: nil),
      animated: true,
      completion: nil
    )
  }
}
