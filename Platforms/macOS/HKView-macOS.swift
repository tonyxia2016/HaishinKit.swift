#if os(macOS)

import AVFoundation
import AppKit

open class HKView: NSView {
    public static var defaultBackgroundColor: NSColor = .black

    public var videoGravity: AVLayerVideoGravity = .resizeAspect {
        didSet {
            layer?.setValue(videoGravity.rawValue, forKey: "videoGravity")
        }
    }
    public var videoFormatDescription: CMVideoFormatDescription? {
        currentStream?.mixer.videoIO.formatDescription
    }

    var position: AVCaptureDevice.Position = .front {
        didSet {
            DispatchQueue.main.async {
                self.layer?.setNeedsLayout()
            }
        }
    }
    var orientation: AVCaptureVideoOrientation = .portrait
    var displayImage: CIImage?

    private weak var currentStream: NetStream? {
        didSet {
            oldValue?.mixer.videoIO.renderer = nil
        }
    }

    override public init(frame: NSRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        layer = AVCaptureVideoPreviewLayer()
        layer?.backgroundColor = HKView.defaultBackgroundColor.cgColor
        layer?.setValue(videoGravity, forKey: "videoGravity")
    }

    open func attachStream(_ stream: NetStream?) {
        currentStream = stream
        guard let stream: NetStream = stream else {
            layer?.setValue(nil, forKey: "session")
            return
        }
        stream.lockQueue.async {
            self.layer?.setValue(stream.mixer.session, forKey: "session")
            stream.mixer.videoIO.renderer = self
            stream.mixer.startRunning()
        }
    }
}

extension HKView: NetStreamRenderer {
    // MARK: NetStreamRenderer
    func draw(image: CIImage?) {
    }
}

#endif
