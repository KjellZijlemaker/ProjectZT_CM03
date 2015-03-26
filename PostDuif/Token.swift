//
//  User.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Token{
    var returnCode: String
    var expireTokenDate: String
    var refreshToken: String
    var token: String
    var status: String
    
    init(){
        self.returnCode = ""
        self.expireTokenDate = ""
        self.refreshToken = ""
        self.token = ""
        self.status = ""
    }
    
    func setReturnCode(returnCode: String){
        self.returnCode = returnCode
    }
    func getReturnCode() -> String{
        return self.returnCode
    }
    func setExpireTokenDate(expireTokenDate: String){
        self.expireTokenDate = expireTokenDate
    }
    func getExpireTokenDate() -> String{
        return self.expireTokenDate
    }
    func setRefreshToken(refreshToken: String){
        self.refreshToken = refreshToken
    }
    func getRefreshToken() -> String{
        return self.refreshToken
    }
    func setToken(token: String){
        self.token = token
    }
    func getToken() -> String{
        return self.token
    }
    func setStatus(status: String){
        self.status = status
    }
    func getStatus() -> String{
        return self.status
    }
    
}
