//
//  LoginAndLogout.swift
//  WePeiYang
//
//  Created by Tigris on 3/8/18.
//  Copyright © 2018 twtstudio. All rights reserved.
//

import Foundation

struct WLANHelper {
    static func login(success: @escaping ()->(), failure: @escaping (String)->()) {
        guard let account = TwTUser.shared.WLANAccount,
            let password = TwTUser.shared.WLANPassword else {
                failure("请绑定个人账号")
                return
        }

        var loginInfo = [String: String]()
        loginInfo["username"] = account
        loginInfo["password"] = password

        SolaSessionManager.solaSession(type: .get, url: WLANLoginAPIs.loginURL, parameters: loginInfo, success: { dict in
            guard let errorCode = dict["error_code"] as? Int,
                let errMsg = dict["message"] as? String else {
                    failure("解析错误")
                    return
            }
            print(errMsg)
            if errorCode == -1 {
                success()
            } else if errorCode == 50002 {
                failure("密码错误")
            } else {
                failure(errMsg)
            }
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }

    static func logout(success: @escaping ()->(), failure: @escaping (String)->()) {
        guard let account = TwTUser.shared.WLANAccount,
            let password = TwTUser.shared.WLANPassword else {
                failure("请绑定账号")
                return
        }

        var loginInfo = [String: String]()
        loginInfo["username"] = account
        loginInfo["password"] = password

        SolaSessionManager.solaSession(type: .get, url: WLANLoginAPIs.loginURL, parameters: loginInfo, success: { dict in
            guard let errorCode = dict["error_code"] as? Int,
                let errMsg = dict["message"] as? String else {
                    failure("解析错误")
                    return
            }

            if errorCode == -1 {
                success()
            } else {
                failure(errMsg)
            }
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }
}