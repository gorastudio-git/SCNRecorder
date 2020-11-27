//
//  MainViewController.swift
//  Example
//
//  Created by VG on 19.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit
import AVKit

final class MainViewController: ViewController {

  static let cellResuseIdentifier = "Cell"

  typealias Item = (title: String, controller: ControllableViewController.Type)
  let items: [Item] = {
    var items = [Item]()
    items.append((title: "ARKit Example", controller: ARKitViewController.self))
    items.append((title: "SceneKit Example", controller: SceneKitViewController.self))
    if #available(iOS 13, *) {
      items.append((title: "RealityKit Example", controller: RealityKitViewController.self))
    }
    items.append( (title: "Metal Example", controller: MetalViewController.self))
    return items
  }()

  // swiftlint:disable force_cast
  lazy var tableView: UITableView = view as! UITableView
  // swiftlint:enable force_cast

  override func loadView() { view = UITableView() }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellResuseIdentifier)
  }
}

extension MainViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: Self.cellResuseIdentifier,
      for: indexPath
    )
    cell.selectionStyle = .none
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = item.title
    return cell
  }
}

extension MainViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let contentController = item.controller.init()
    let controlsController = ControlsViewController(contentController)
    controlsController.delegate = self
    navigationController?.pushViewController(controlsController, animated: true)
  }
}

extension MainViewController: ControlsViewControllerDelegate {

  func controlsViewControllerDidTakePhoto(_ photo: UIImage) {
    let controller = PhotoPreviewController(photo: photo)
    navigationController?.pushViewController(controller, animated: true)
  }

  func controlsViewControllerDidTakeVideoAt(_ url: URL) {
    let controller = VideoPreviewController(videoURL: url)
    navigationController?.pushViewController(controller, animated: true)
  }
}
