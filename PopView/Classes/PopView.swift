
import UIKit
import Then


public class PopView: UIView {
    
    var config: Config = .default
    
    var actions: [Action]
    
    var shapeLayer = CAShapeLayer()
    var backgroundLayer = CAShapeLayer()
    
    lazy var tableView = UITableView().then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        $0.rowHeight = config.rowHeight
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .singleLine
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.separatorColor = UIColor(displayP3Red: 0.25, green: 0.25, blue: 0.25, alpha: 0.125)
    }
    
    public init(_ actions: [Action]) {
        self.actions = actions
        super.init(frame: UIScreen.main.bounds)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        backgroundColor = .white
        setupMaskLayer()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        addSubview(tableView)
    }
    
    public func show(at point: CGPoint) {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        setupBackgroundLayer()
        let p = refix(point: point)
        updatePath(with: p)
        tableView.reloadData()
        tableView.frame = makeBorderBounds(with: p)
        makeAnimation(with: p)
    }
    
    @objc public func dismiss(_: Any) {
        removeFromSuperview()
        backgroundLayer.removeFromSuperlayer()
    }
}

extension PopView {

    func setupMaskLayer() {
        shapeLayer.fillColor = UIColor.orange.cgColor
        layer.mask = shapeLayer
    }
    
    func setupBackgroundLayer() {
        backgroundLayer.frame = bounds
        backgroundLayer.backgroundColor = UIColor.lightGray.cgColor
        backgroundLayer.opacity = 0.3
        superview?.layer.insertSublayer(backgroundLayer, below: self.layer)
    }
    
    func makeAnimation(with point: CGPoint) {
        let frame = bounds
        shapeLayer.anchorPoint = CGPoint(
            x: point.x / bounds.width,
            y: point.y / bounds.height
        )
        shapeLayer.frame = frame
        shapeLayer.setAffineTransform(CGAffineTransform(scaleX: 0.01, y: 0.01))
        shapeLayer.opacity = 0
        tableView.alpha = 0
        CATransaction.begin()
        CATransaction.disableActions()
        CATransaction.setAnimationDuration(2)
        CATransaction.setCompletionBlock {
            self.shapeLayer.setAffineTransform(.identity)
            self.shapeLayer.opacity = 1
            self.tableView.alpha = 1
        }
        CATransaction.commit()
    }
    
    func updatePath(with point: CGPoint) {
        let arrow = makeArrowPath(at: point)
        let path = makeBorderPath(at: point)
        path.append(arrow)
        shapeLayer.path = path.cgPath
    }
    
    func makeBorderPath(at point: CGPoint) -> UIBezierPath {
        let bounds = makeBorderBounds(with: point)
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: config.cornerRadius, height: config.cornerRadius)
        )
        return path
    }
    
    func makeBorderBounds(with point: CGPoint) -> CGRect {
        let screenWidth = self.bounds.width - config.margin * 2
        // 箭头默认居中
        var x = point.x - config.width / 2
        // 超出屏幕右侧时，箭头需要往右边移
        let diffRight = point.x + config.width / 2 - screenWidth
        if diffRight > 0 {
            x -= diffRight
        } else if x < 0 {
            x = config.margin
        }
        let height = min(maxHeight(), CGFloat(actions.count) * config.rowHeight)
        return CGRect(x: x, y: point.y + config.arrowHeight, width: config.width, height: height)
    }
    
    func makeArrowPath(at point: CGPoint) -> UIBezierPath {
        let arrowPath = UIBezierPath()
        arrowPath.move(to: point)
        arrowPath.addLine(to: CGPoint(x: point.x + config.arrowHeight / 2, y: point.y + config.arrowHeight))
        arrowPath.addLine(to: CGPoint(x: point.x - config.arrowHeight / 2, y: point.y + config.arrowHeight))
        arrowPath.close()
        return arrowPath
    }
    
    private func maxHeight(_ top: CGFloat = 0) -> CGFloat {
        return bounds.height - top - config.arrowHeight
    }
    
    /// 修正指向位置（如超出屏幕边界）
    private func refix(point: CGPoint) -> CGPoint {
        var p = point
        let minX = config.margin + config.arrowHeight / 2
        let maxX = bounds.width - config.margin - config.arrowHeight / 2
        p.x = max(minX, p.x)
        p.x = min(maxX, p.x)
        return p
    }
}

extension PopView {
    public struct Config {
        var rowHeight: CGFloat = 45
        var width: CGFloat = 125
        var cornerRadius: CGFloat = 8
        var arrowHeight: CGFloat = 15
        var margin: CGFloat = 10
        var textColor: UIColor = .darkGray
        var font: UIFont = .systemFont(ofSize: 14)
        
        static var `default` = Config()
    }
    
    public struct Action {
        var title: String
        var handle: () -> Void
        var icon: UIImage?
        
        public init(title: String, icon: UIImage? = nil, handle: @escaping () -> Void) {
            self.title = title
            self.icon = icon
            self.handle = handle
        }
    }
}

extension PopView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = actions[indexPath.row].title
        cell.textLabel?.textColor = config.textColor
        cell.textLabel?.font = config.font
        cell.imageView?.image = actions[indexPath.row].icon
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(displayP3Red: 0.125, green: 0.125, blue: 0.125, alpha: 0.125)
        cell.selectedBackgroundView = selectedView
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actions[indexPath.row].handle()
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.dismiss(1)
        }
    }
}

extension PopView : UIGestureRecognizerDelegate {
    /// 排除落在TableView的手势
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if tableView.bounds.contains(touch.location(in: tableView)) {
            return false
        }
        return true
    }
}
