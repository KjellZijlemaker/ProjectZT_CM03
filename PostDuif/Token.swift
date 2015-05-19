//
//  User.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Model for saving the token

import Foundation

class Token{
    private var returnCode: String
    private var expireTokenDate: String
    private var refreshToken: String
    private var gotRefreshToken: Bool
    private var token: String
    private var status: String
    private var message: String
    
    init(){
        self.returnCode = ""
        self.expireTokenDate = ""
        self.refreshToken = ""
        self.token = ""
        self.status = ""
        self.message = ""
        self.gotRefreshToken = true
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
    func setMessage(message: String){
        self.message = message
    }
    func getMessage() -> String{
        return self.message
    }
    func isRefreshToken() -> Bool{
        return self.gotRefreshToken
    }
    func hasRefreshToken(refreshToken: Bool){
        self.gotRefreshToken = refreshToken
    }
    
}
