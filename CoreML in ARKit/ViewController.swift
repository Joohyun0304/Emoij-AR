
import UIKit
import SceneKit
import ARKit
import SensingKit
import Foundation
import AVFoundation
import CoreAudio
import Photos
import SceneKitVideoRecorder


var timer: Timer!

// default emoji
var emojiValue = "emoji/default.png"


class ViewController: UIViewController, ARSCNViewDelegate {
   
    var videoRecorder: SceneKitVideoRecorder?
    var isRecording = false

    
    // audio recorder config
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var thresholdTimer = Timer()
    let LEVEL_THRESHOLD: Float = -20.0
    
    
    // SCENE
    @IBOutlet var sceneView: ARSCNView!
    let bubbleDepth : Float = 0.01 // the 'depth'
    
    // sensing kit
    let sensingKit = SensingKitLib.shared()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        videoRecorder = try! SceneKitVideoRecorder(withARSCNView: sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Enable Default Lighting
        sceneView.autoenablesDefaultLighting = true
        
        
        
        
        // battery
//        do {
//            try sensingKit.register(SKSensorType.Battery)
//        }
//        catch {
//            // Handle error
//        }
//        do {
//            try sensingKit.subscribe(to: SKSensorType.Battery, withHandler: { (sensorType, sensorData, error) in
//                
//                if (error == nil) {
//                    let batteryData = sensorData as! SKBatteryData
//                    
//                    if(batteryData.level < 0.05){
//                        emojiValue = "emoji/zombie.png"
//                    }
//                    
//                    if(batteryData.level == 1.0){
//                        emojiValue = "emoji/star.png"
//                    }
//                    
//                    if(batteryData.stateString == "Charging"){
//                        emojiValue = "emoji/money.png"
//                    }
//                    
//                    //                    else {emojiValue = "emoji/default.png"}
//                    
//                print("Battery Data: \(batteryData.stateString)")
//                } else {
//                    print("ERROR GETTING DATA")
//                }
//            })
//        }
//        catch {
//            // Handle error
//        }
//        do {
//            try sensingKit.startContinuousSensing(with: SKSensorType.Battery)
//        }
//        catch {
//            // Handle error
//        }
        
        
        
        
        // gyro
        do {
            try sensingKit.register(SKSensorType.Gyroscope)
        }
        catch {
            // Handle error
        }
        do {
            try sensingKit.subscribe(to: SKSensorType.Gyroscope, withHandler: { (sensorType, sensorData, error) in
                
      
                if (error == nil) {
                    let gyroscopeData = sensorData as! SKGyroscopeData
                    
                    if (gyroscopeData.rotationRate.z > 0.8 || gyroscopeData.rotationRate.z < -0.8 || gyroscopeData.rotationRate.x > 0.8 || gyroscopeData.rotationRate.x < -0.8) {
                        emojiValue = "emoji/dizzy.png"
                        
                    }
                        
                    else {emojiValue = "emoji/default.png"}
                    
                    
                    // ambient light
                    let light = self.sceneView.session.currentFrame?.lightEstimate?.ambientIntensity
//                                        print(light)
                    
                    guard let validLightReading = light else {
                        return;
                    }
                    
                    if (validLightReading > 1200) {
                        emojiValue = "emoji/sunglasses.png"
                    }
                    if (validLightReading < 100) {
                        emojiValue = "emoji/alien.png"
                    }
                    
                    
                } else {
                    print("ERROR GETTING DATA")
                }
            })
        }
        catch {
            // Handle error
        }
        do {
            try sensingKit.startContinuousSensing(with: SKSensorType.Gyroscope)
        }
        catch {
            // Handle error
        }
        
        
        
        // accelero
        do {
            try sensingKit.register(SKSensorType.Accelerometer)
        }
        catch {
            // Handle error
        }
        do {
            try sensingKit.subscribe(to: SKSensorType.Accelerometer, withHandler: { (sensorType, sensorData, error) in
                
                if (error == nil) {
                    let accelerometerData = sensorData as! SKAccelerometerData
                    
                    if (accelerometerData.acceleration.x > 0.95 || accelerometerData.acceleration.x < -0.95 || accelerometerData.acceleration.y > 0.95 || accelerometerData.acceleration.y < -0.95 ||
                        accelerometerData.acceleration.z > 0.95 || accelerometerData.acceleration.z < -0.95 ) {
                        emojiValue = "emoji/crazy.png"
                    }
                        
//                    else {emojiValue = "emoji/default.png"}
                    //                    print("Accelerometer Data: \(accelerometerData)")
                } else {
                    print("ERROR GETTING DATA")
                }
            })
        }
        catch {
            // Handle error
        }
        do {
            try sensingKit.startContinuousSensing(with: SKSensorType.Accelerometer)
        }
        catch {
            // Handle error
        }
        
        
        
        
        
        // motion activity
        do {
            try sensingKit.register(SKSensorType.MotionActivity)
        }
        catch {
            // Handle error
        }
        do {
            try sensingKit.subscribe(to: SKSensorType.MotionActivity, withHandler: { (sensorType, sensorData, error) in
                
                if (error == nil) {
                    let motionActivityData = sensorData as! SKMotionActivityData
                    
                    if ( motionActivityData.motionActivity.walking == true ) {
                        emojiValue = "emoji/walking.png"
                    }
                    if ( motionActivityData.motionActivity.running == true ) {
                        emojiValue = "emoji/running.png"
                    }
                    if ( motionActivityData.motionActivity.automotive == true ) {
                        emojiValue = "emoji/wink.png"
                    }
                    if ( motionActivityData.motionActivity.cycling == true ) {
                        emojiValue = "emoji/cycling.png"
                    }

//                    else {emojiValue = "emoji/default.png"}
                    
                    //                        print("MotionActivity Data: \(motionActivityData)")
                } else {
                    print("ERROR GETTING DATA")
                }
            })
        }
        catch {
            // Handle error
        }
        do {
            try sensingKit.startContinuousSensing(with: SKSensorType.MotionActivity)
        }
        catch {
            // Handle error
        }
        

        
        
        
   
        
        
        
        
        
        
        // external audio level data
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
            
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        
        
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
        
        thresholdTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(thresholdLevelTimerCallback), userInfo: nil, repeats: true)
        
      
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
    }
    

    
     var thresholdLevel = Float()
    
    
    // update sound threshold every 5 seconds to environment
     @objc func thresholdLevelTimerCallback() {
        recorder.updateMeters()
        thresholdLevel = recorder.averagePower(forChannel: 0) + 12

    }
    
    // update level data
    @objc func levelTimerCallback() {
        recorder.updateMeters()
        
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > thresholdLevel
        
//        print(level)
        
        if(isLoud){
            
            emojiValue = "emoji/shit.png"
            
        }
    }
    
    
    
    func createNewEmojiParentNode() -> SCNNode {
        
        // TEXT BILLBOARD CONSTRAINT
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        
        // POINT NODE
        let point = SCNPlane(width: 0.02, height: 0.02)
        point.firstMaterial?.diffuse.contents = emojiValue
        let pointNode = SCNNode(geometry: point)
        
        
        // PARENT NODE
        let emojiNodeParent = SCNNode()
        emojiNodeParent.addChildNode(pointNode)
        emojiNodeParent.constraints = [billboardConstraint]
        
        return emojiNodeParent
    }
    
    
    
    @objc func update() {
        self.updateEmoji()
    }
    
    
    
    func updateEmoji() {
        // Get Screen Center
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Create 3D Text
            let node : SCNNode = createNewEmojiParentNode()
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
    
    @IBAction func handleRecordButton(_ sender: UIButton) {
        // Toggle start/stop recording.
        isRecording = !isRecording
        
        if isRecording {
            sender.setTitle("Stop Recording", for: .normal)
            
            let btnImage1 = UIImage(named: "button2.png")
            sender.setImage(btnImage1 , for: UIControlState.normal)
        
            self.videoRecorder?.startWriting().onSuccess {

            }
        } else {
            sender.setTitle("Start Recording", for: .normal)
        
            let btnImage2 = UIImage(named: "button.png")
            sender.setImage(btnImage2 , for: UIControlState.normal)
            
            self.videoRecorder?.finishWriting().onSuccess { [weak self] url in

                self?.checkAuthorizationAndPresentActivityController(toShare: url, using: self!)
            }
        }
    }
    
    private func checkAuthorizationAndPresentActivityController(toShare data: Any, using presenter: UIViewController) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.print]
            presenter.present(activityViewController, animated: true, completion: nil)
        case .restricted, .denied:
            let libraryRestrictedAlert = UIAlertController(title: "Photos access denied",
                                                           message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.",
                                                           preferredStyle: UIAlertControllerStyle.alert)
            libraryRestrictedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            presenter.present(libraryRestrictedAlert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.print]
                    presenter.present(activityViewController, animated: true, completion: nil)
                }
            })
        }
    }
    

    
    
    
}

