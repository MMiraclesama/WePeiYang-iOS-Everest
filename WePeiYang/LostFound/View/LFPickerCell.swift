//
//  LFPickerCell.swift
//  WePeiYang
//
//  Created by Hado on 2017/9/27.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import SnapKit

class LFPickerCell: UITableViewCell {
    
    var pickerView: UIPickerView!
    var textField: UITextField!
    
    
    let dateArr = ["7天","15天","30天"]
    override var frame: CGRect{
        
        didSet{
            var newFrame = frame;
            newFrame.origin.x += 10;
            newFrame.size.width -= 20;
            newFrame.origin.y += 10;
            //            newFrame.size.height -= 10;
            super.frame = newFrame;
            
        }
    }
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        toolBar.barStyle = UIBarStyle.default
        
        var btnFished = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
        
        btnFished.setTitle("完成", for: .normal)
        btnFished.addTarget(self, action: #selector(finishTapped(sender:)), for: .touchUpInside)
        var item2 = UIBarButtonItem(customView: btnFished)
//        var space = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - btnFished.frame.width - 30, height: 25)）
        let space = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-btnFished.frame.size.width-30, height: 25))
        
        var item = UIBarButtonItem(customView: space)
        toolBar.setItems([item, item2], animated: true)
//        self.inputAccessoryView = toolBar
        textField.inputAccessoryView = toolBar
        
        
    }
    
    //    func screenSize() -> CGRect {
    //    return UIScreen.main.bounds.size
    //    }
    
    func finishTapped(sender: UIButton) {
        
        self.resignFirstResponder()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        
        
        
        pickerView = UIPickerView()
        textField = UITextField()
        textField.inputView = pickerView
        textField.borderStyle = .roundedRect
        textField.placeholder = "请输入天数"
        
        textField.textAlignment = .center
        self.addSubview(textField)
        
        
        //        pickerView.selectRow(1, inComponent: 0, animated: true)
        //        self.addSubview(pickerView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        textField.delegate = self
        
        
        textField.snp.makeConstraints{
            
            make in
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(180)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(30)
        }
        //        pickerView.snp.makeConstraints {
        //            make in
        //            make.left.equalToSuperview().offset(80)
        //            make.right.equalToSuperview().offset(-5)
        //            make.top.equalToSuperview().offset(5)
        //            make.bottom.equalToSuperview().offset(-5)
        //        }
    }
    
    
}

extension LFPickerCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dateArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        
        self.textField.text = dateArr[row]
        //
        //        let textField = UITextField()
        //        textField.text = dateArr[row]
    }
    
    
    
}

extension LFPickerCell: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dateArr.count
    }
}

extension LFPickerCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
}

