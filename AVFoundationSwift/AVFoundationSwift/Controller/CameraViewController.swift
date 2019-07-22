//
//  CameraViewController.swift
//  AVFoundationSwift
//
//  Created by Rubaiyat Jahan Mumu on 7/15/19.
//  Copyright © 2019 Rubaiyat Jahan Mumu. All rights reserved.
//

import UIKit
import Photos

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: CustomButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var toggleCameraButton: UIButton!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraSelectionButton: UIButton!
    @IBOutlet weak var videoCameraButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    
    var cameraConfig: CameraConfiguration!
    let imagePickerController = UIImagePickerController()
    
    var videoRecordingStarted: Bool = false {
        didSet{
            if videoRecordingStarted {
                self.cameraButton.backgroundColor = UIColor.red
            } else {
                self.cameraButton.backgroundColor = UIColor.white
            }
        }
    }
    
    func checkPermission(completion: @escaping ()->Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            completion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    completion()
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    fileprivate func registerNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name(rawValue: "App is going background"), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        if videoRecordingStarted {
            videoRecordingStarted = false
            self.cameraConfig.stopRecording { (error) in
                print(error ?? "Video recording error")
            }
        }
    }
    
    @IBAction func gotoGallery(_ sender: Any) {
        checkPermission(completion: {
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.delegate = self
            
            self.imagePickerController.mediaTypes = ["public.image", "public.movie"]
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
    }
    
    @objc func appCameToForeground() {
        print("app enters foreground")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraConfig = CameraConfiguration()
        cameraConfig.setup { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            try? self.cameraConfig.displayPreview(self.previewImageView)
        }
        self.cameraButton.setImage(#imageLiteral(resourceName: "camera"), for: .normal)
        self.cameraButton.tintColor = UIColor.black
        self.galleryButton.setImage(#imageLiteral(resourceName: "photo_icon"), for: .normal)
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func toggleFlash(_ sender: Any) {
        if cameraConfig.flashMode == .on {
            cameraConfig.flashMode = .off
            self.toggleFlashButton.setImage(#imageLiteral(resourceName: "flash_off"), for: .normal)
        } else if cameraConfig.flashMode == .off {
            cameraConfig.flashMode = .on
            self.toggleFlashButton.setImage(#imageLiteral(resourceName: "flash_on"), for: .normal)
        } else {
            cameraConfig.flashMode = .auto
            self.toggleFlashButton.setImage(#imageLiteral(resourceName: "flash_auto"), for: .normal)
        }
    }
    
    @objc fileprivate func showToastForSaved() {
        showToast(message: "Saved!", fontSize: 12.0)
    }
    
    @objc fileprivate func showToastForRecordingStopped() {
        showToast(message: "Recording Stopped", fontSize: 12.0)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showToast(message: "Could not save!! \n\(error)", fontSize: 12)
        } else {
            showToast(message: "Saved", fontSize: 12.0)
            self.galleryButton.setImage(image, for: .normal)
        }
    }
    
    @objc func video(_ video: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            
            showToast(message: "Could not save!! \n\(error)", fontSize: 12)
        } else {
            showToast(message: "Saved", fontSize: 12.0)
        }
        print(video)
    }
    
    @IBAction func didTapOnTakePhotoButton(_ sender: Any) {
        if self.cameraConfig.outputType == .photo {
            self.cameraConfig.captureImage { (image, error) in
                guard let image = image else {
                    
                    print(error ?? "Image capture error")
                    return
                }
                self.previewImageView.image = image
//                try? PHPhotoLibrary.shared().performChangesAndWait {
//                    PHAssetChangeRequest.creationRequestForAsset(from: image)
//                }
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } else {
            if videoRecordingStarted {
                videoRecordingStarted = false
                self.cameraConfig.stopRecording { (error) in
                    print(error ?? "Video recording error")
                }
            } else if !videoRecordingStarted {
                videoRecordingStarted = true
                self.cameraConfig.recordVideo { (url, error) in
                    guard let url = url else {
                        print(error ?? "Video recording error")
                        return
                    }
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    
    
    @IBAction func toggleCamera(_ sender: Any) {
        do {
            try cameraConfig.switchCameras()
        } catch {
            print(error.localizedDescription)
        }
        
//        switch cameraConfig.currentCameraPosition {
//        case .some(.front):
//            self.toggleCameraButton.setImage(#imageLiteral(resourceName: "camera_front"), for: .normal)
//        case .some(.rear):
//            self.toggleCameraButton.setImage(#imageLiteral(resourceName: "camera_rear"), for: .normal)
//        default:
//            return
//        }
    }
    @IBAction func selectVideoMode(_ sender: Any) {
        self.cameraConfig.outputType = .video
        self.cameraButton.setImage(#imageLiteral(resourceName: "videocam"), for: .normal)
    }
    @IBAction func selectCameraMode(_ sender: Any) {
        self.cameraConfig.outputType = .photo
        self.cameraButton.setImage(#imageLiteral(resourceName: "camera"), for: .normal)
    }
    
}

//Disabling Xcode’s OS-Level Debug Logging
//1- From Xcode menu open: Product > Scheme > Edit Scheme
//2- On your Environment Variables set OS_ACTIVITY_MODE in the value set disable
// this will stop the warning but not the error

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.galleryButton.contentMode = .scaleAspectFit
            self.galleryButton.setImage( pickedImage, for: .normal)
        }
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print("videoURL:\(String(describing: videoURL))")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
