//
//  CLMenuView.swift
//  CLMenuView
//

import UIKit

public enum menuItemType {
    case inputimage       //图片导入
    case tailor   //裁剪
    case blushselect    //画笔选择
}

/// 点击代理回调
@objc (ClMenuItemViewDelegate)
public protocol ClMenuItemViewDelegate:NSObjectProtocol {
    //回调每个item的index
    @objc func menuItemAction(itemIndex:Int, sender:UIButton)
}

@objcMembers
public class CLMenuView: UIView {
    
    fileprivate var isShowMenuView:Bool = false
    fileprivate var isFinishedInit:Bool = false
    
    //MARK:公共属性
    //代理回调
    @objc weak public var delegate:ClMenuItemViewDelegate?
    // 闭包回调
    public var clickMenuitemIndex:((_ itemIndex:Int)->())?
    
    //显示menuView
    public func showMenuItemView(){
        showMenuView()
    }
    
    public func isShow() ->Bool{
        return isShowMenuView
    }
    
    /// 隐藏menuView
    public func hiddenMenuItemView(){
        hideMenuView()
    }
    
    fileprivate func showMenuView(){
        isShowMenuView = true
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
    fileprivate func hideMenuView(){
        isShowMenuView = false
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.0
        }) { (isComplete) in
//            if self.superview == nil {return}
//            self.removeFromSuperview()
        }
    }
    //MARK: 私有属性
    fileprivate var menuItems:[menuItemType]?
    fileprivate var itemCount:Int = 0
    
    fileprivate lazy var containerView:UIView = UIView()
    fileprivate lazy var backgroundImageView:UIImageView = {
        let backImageView = UIImageView()
        let bgImage = UIImage(named: "cl_menu_longpress_bg", in: Bundle(for: CLMenuView.self), compatibleWith: nil)
        let left:Int = Int((bgImage?.size.width)! * 0.5)
        let top:Int = Int((bgImage?.size.height)! * 0.5)
        backImageView.image = bgImage?.stretchableImage(withLeftCapWidth: left, topCapHeight: top)
        backImageView.isUserInteractionEnabled = true
        return backImageView
    }()
    fileprivate lazy var arrowImageView:UIImageView = UIImageView()
    
    
    //初始化方法
    public init() {
        super.init(frame: .zero)
        let itemTypes = [menuItemType.inputimage,menuItemType.tailor,menuItemType.blushselect];
        self.alpha = 0
        self.menuItems = itemTypes
        self.itemCount = itemTypes.count
        
        setUpUI()
        
    }
    
    //设置控件frame
    @objc public func setTargetRect(targetRect:CGRect){
        setMenuViewFrame(targetRect:targetRect)
        if isFinishedInit {return}
        initData()
        isFinishedInit = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc public func clickItemButton(sender:UIButton){
        
        delegate?.menuItemAction(itemIndex: sender.tag, sender: sender)
        
        clickMenuitemIndex?(sender.tag)
    }
}

public extension CLMenuView
{
    
    fileprivate func setUpUI(){
        addSubview(backgroundImageView)
        addSubview(arrowImageView)
    }
    
    fileprivate func initData(){
        backgroundImageView.addSubview(containerView)
        containerView.frame = CGRect(x: 0, y: 8, width: backgroundImageView.bounds.size.width, height: backgroundImageView.bounds.size.height)
        
        guard let items = self.menuItems else {
            return
        }
        
        for (index,element) in items.enumerated() {
            
            let menuBtn = UIButton()
            menuBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            menuBtn.setTitleColor(UIColor.cl_colorWithHex(hex: 0xd4d4d4), for: UIControl.State.normal)
            menuBtn.addTarget(self, action: #selector(clickItemButton(sender:)), for: UIControl.Event.touchUpInside)
            menuBtn.tag = index
            
            var title:String
            var imageName:String
            switch element {
            case .inputimage:
                title = "图片导入"
                imageName = "bottom_bar_input_img"
                break;
            case .tailor:
                title = "裁剪"
                imageName = "bottom_bar_crop"
                break;
            case .blushselect:
                title = "画笔调整"
                imageName = "bottom_bar_blur"
                break;
            }
            menuBtn.setTitle(title, for: UIControl.State.normal)
           menuBtn.setImage(UIImage(named: imageName, in: Bundle(for: CLMenuView.self), compatibleWith: nil), for: .normal)
            menuBtn.cl_ButtonPostion(postion: .top, spacing: 3)
            
            containerView.addSubview(menuBtn)
            menuBtn.frame = CGRect(x: CGFloat(index) * (containerView.bounds.size.width / CGFloat(itemCount)), y: 0, width: containerView.bounds.size.width / CGFloat(itemCount), height: containerView.bounds.size.height)
        }
        
        
    }
    
    fileprivate func setMenuViewFrame(targetRect:CGRect){
        
        let screenW = UIScreen.main.bounds.size.width
        let screenH = UIScreen.main.bounds.size.height
        let itemW:CGFloat = 66.0
        let targetCenterX = targetRect.origin.x + targetRect.size.width / 2 - 40
        let menuW:CGFloat = CGFloat(itemCount) * itemW
        let menuH:CGFloat = 58.0
        var menuX = targetCenterX - menuW / 2 > 0 ? targetCenterX - menuW / 2 : 0
        menuX = menuX + menuW > screenW ? screenW - menuW : menuX
        var menuY:CGFloat = targetRect.origin.y - menuH
        // 避免 MenuController 过于靠上
        menuY = menuY < 20 ? targetRect.origin.y + targetRect.size.height : menuY
        // 适配特别长的文本，直接显示在屏幕中间
        menuY = menuY > screenH - menuH - 30 ? screenH / 2 : menuY
        
        let frame = CGRect(x: menuX, y: menuY, width: menuW, height: menuH)
        
        self.frame = frame
        
        let arrowH:CGFloat = 8.0
        let arrowW:CGFloat = 12.0
        let arrowX:CGFloat = targetRect.origin.x - frame.origin.x + 0.5 * targetRect.size.width - arrowW / 2 - 40
      
            //箭头向下
            backgroundImageView.frame = CGRect(x: 0, y: 0, width: menuW, height: menuH - arrowH)
            arrowImageView.image = UIImage(named: "cl_menu_longpress_down_arrow", in: Bundle(for: CLMenuView.self), compatibleWith: nil)
            arrowImageView.frame = CGRect(x: arrowX, y: menuH - arrowH, width: arrowW, height: arrowH)
        
        
    }
}

public extension UIColor {
    
    public class func cl_colorWithHex(hex:UInt32) ->UIColor {
        let r = (hex & 0xFF0000)>>16
        let g = (hex & 0x00FF00)>>8
        let b = (hex & 0x0000FF)
        
        return UIColor(red: CGFloat(Float(r)/255.0), green:CGFloat(Float(g)/255.0) , blue: CGFloat(Float(b)/255.0), alpha: 1.0)
    }
}

public extension UIButton{
    enum ClImagePosition {
        case left    //图片在左，文字在右，默认
        case right   //图片在右，文字在左
        case top     //图片在上，文字在下
        case bottom  //图片在下，文字在上
    }
    func cl_ButtonPostion(postion:ClImagePosition,spacing:CGFloat){
        
        let imageWith = self.imageView?.image?.size.width
        let imageHeight = self.imageView?.image?.size.height
        let labelSize = titleLabel?.attributedText?.size()
        let imageOffsetX = (imageWith! + (labelSize?.width)!) / 2 - imageWith! / 2
        let imageOffsetY = imageHeight! / 2 + spacing / 2
        let labelOffsetX = (imageWith! + (labelSize?.width)! / 2) - (imageWith! + (labelSize?.width)!) / 2
        let labelOffsetY = (labelSize?.height)! / 2 + spacing / 2
        
        switch postion {
        case .left:
            self.imageEdgeInsets = UIEdgeInsets(top:0,left:-spacing/2,bottom:0, right:spacing/2)
            self.titleEdgeInsets = UIEdgeInsets(top:0, left:spacing/2, bottom:0, right:-spacing/2)
            break
        case .right:
            self.imageEdgeInsets = UIEdgeInsets(top:0, left:(labelSize?.width)! + spacing/2, bottom:0,right: -((labelSize?.width)! + spacing/2))
            self.titleEdgeInsets = UIEdgeInsets(top:0, left:-(imageHeight! + spacing/2), bottom:0, right:imageHeight! + spacing/2)
            break
        case .top:
            self.imageEdgeInsets = UIEdgeInsets(top:-imageOffsetY, left:imageOffsetX, bottom:imageOffsetY, right:-imageOffsetX)
            self.titleEdgeInsets = UIEdgeInsets(top:labelOffsetY, left:-labelOffsetY - 5, bottom:-labelOffsetY, right:labelOffsetX)
            break
        case .bottom:
            self.imageEdgeInsets = UIEdgeInsets(top:imageOffsetY, left:imageOffsetX, bottom:-imageOffsetY, right:-imageOffsetX)
            self.titleEdgeInsets = UIEdgeInsets(top:-labelOffsetY, left:-labelOffsetX, bottom:labelOffsetY, right:labelOffsetX)
            break
            
        }
        
    }
}
