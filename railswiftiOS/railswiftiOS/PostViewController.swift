//
//  PostViewController.swift
//  railswiftiOS
//
//  Created by 水野徹 on 2018/09/17.
//  Copyright © 2018年 Toru Mizuno. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PostViewController: UIViewController {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var accesstoken: String!
    var client: String!
    var uid:String!
    var webuser: Webuser!
    
    //画像を保存する際に取得する画像名を入れる変数
    fileprivate var postImagerandomString: String!
    //画像を保存する際に取得するタイトルを入れる変数
    fileprivate var titleNamerandomString: String!
    
    var posts = [Post]()//全てのPostデータを入れる変数
    var myposts = [Post]()//自分のPostデータを入れる変数

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //appDelegateからアクセス制限用のトークンと、通信したいuserの情報を取ってくる
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        webuser = appDelegate.webuser
        accesstoken = appDelegate.accesstoken
        client = appDelegate.client
        uid = appDelegate.uid
        print("\(webuser)")
        print("\(accesstoken)")
        print("\(client)")
        print("\(uid)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //ランダムに文字列を生成してくれる関数
    func generate(length: Int) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    
    
    //indexアクション
    //全てのpostを取ってくる
    @IBAction func indexPostButtonClicked(_ sender: Any) {
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = self.accesstoken
            headers["client"] = self.client
            headers["uid"] = self.uid
            
            print("accesstoken: \(String(describing: self.accesstoken))")
            print("client: \(String(describing: self.client))")
            print("uid: \(String(describing: self.uid))")
            
            //GET /api/posts(.:format)
            Alamofire.request("http://localhost:3000/api/posts", method: .get, headers: headers).responseJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                //アクセスできた場合
                if response.response?.statusCode == 200 {
                    print("通信に成功しました")
                    
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    print("Error: \(String(describing: response.error))")
                    
                    //エラーがなかった場合
                    if response.error == nil {
                        
                        self.posts.removeAll()
                        
                        //responseから保存したデータのIDを抜き出す
                        let json:JSON = JSON(response.result.value ?? kill)
                        
                        json.forEach { (arg) in
                            let (_, json) = arg
                            
                            //Postに保存
                            let post = Post()
                            
                            //パラメーターセット
                            post.id = json["id"].intValue
                            post.web_user_id = json["web_user_id"].intValue
                            post.postImage = json["post_image"]["url"].stringValue
                            post.titlename = json["title_name"].stringValue
                            
                            print("id: \(String(describing: post.id))")
                            print("web_user_id: \(String(describing: post.web_user_id))")
                            print("post_image: \(String(describing: post.postImage))")
                            print("title_name: \(String(describing: post.titlename))")
                            
                            self.posts.append(post)
                        }
                        
                    }
                    
                    //アクセスできなかった場合
                } else {
                    
                    print("アクセスできませんでした")
                    
                }
                
            }
            
            //ヘッダー情報を取ってこれていなかった場合
        } else {
            
            //ログインしていないと警告を出す
            
        }
        
    }
    
    
    
    
    
    //showアクション
    //postのidで取ってくる
    @IBAction func showPostButtonClicked(_ sender: Any) {
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            let postid: Int = Int(self.idTextField.text!)!//TextFieldにIDを入力しないとエラーになるよ
            let accesstoken: String = self.accesstoken
            let client: String = self.client
            let uid: String = self.uid
            
            print("postid: \(String(describing: postid))")
            print("accesstoken: \(String(describing: accesstoken))")
            print("client: \(String(describing: client))")
            print("uid: \(String(describing: uid))")
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = accesstoken
            headers["client"] = client
            headers["uid"] = uid
            
            print("requestURL_post: http://localhost:3000/api/posts/\(postid)")
            
            //GET /api/posts/:id(.:format)
            //ログインした際にとって来たトークン情報と、自分のwebuserid(アカウントID)を使って自分のpostのみを取ってくる
            Alamofire.request("http://localhost:3000/api/posts/\(postid)", method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                //アクセスできた場合
                if response.response?.statusCode == 200 {
                    
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    print("Error: \(String(describing: response.error))")
                    print("Value: \(String(describing: response.result.value))")
                    
                    //responseから保存したデータのIDを抜き出す
                    let json:JSON = JSON(response.result.value ?? kill)
                    print("json: \(String(describing: json))")
                    
                    //Postに保存
                    let post = Post()
                    
                    //パラメーターセット
                    post.id = json["id"].intValue
                    post.web_user_id = json["web_user_id"].intValue
                    post.postImage = json["post_image"]["url"].stringValue
                    post.titlename = json["title_name"].stringValue
                    
                    print("id: \(String(describing: post.id))")
                    print("web_user_id: \(String(describing: post.web_user_id))")
                    print("post_image: \(String(describing: post.postImage))")
                    print("title_name: \(String(describing: post.titlename))")
                    
                    self.myposts.append(post)
                    
                    //アクセスできなかった場合は再度取ってくるように通信する
                } else {
                    
                    //アクセスできなかった場合は再度取ってくるように通信する
                    
                    print("Error: \(String(describing: response.error))")
                }
                
            }
            
            //ヘッダー情報を取ってこれていなかった場合
        } else {
            
            //ログインしていないと警告を出す
            
        }
        
        
    }
    
    
    
    
    
    
    //createアクション
    //普通に保存する
    @IBAction func createPostButtonClicked(_ sender: Any) {
        
        let rndstr = generate(length: 32)
        
        //パラメーターを辞書で入れていく//左辺がカラム名、右辺が値
        var params: [String: Any] = [:]
        params["web_user_id"] = webuser.web_user_id
        params["title_name"] = rndstr
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = self.accesstoken
            headers["client"] = self.client
            headers["uid"] = self.uid
            
            print("accesstoken: \(String(describing: self.accesstoken))")
            print("client: \(String(describing: self.client))")
            print("uid: \(String(describing: self.uid))")
            
            //POST /api/posts(.:format)
            Alamofire.request("http://localhost:3000/api/posts", method: .post, parameters: params, headers: headers).responseJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                //アクセスできた場合
                if response.response?.statusCode == 200 {
                    print("通信に成功しました")
                    
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    print("Error: \(String(describing: response.error))")
                    
                    //エラーがなかった場合
                    if response.error == nil {
                        let json:JSON = JSON(response.result.value ?? kill)
                        print("json: \(String(describing: json))")
                        
                        //Postに保存
                        let post = Post()
                        
                        post.id = json["id"].intValue
                        post.web_user_id = json["web_user_id"].intValue
                        post.titlename = json["title_name"].stringValue
                        
                        print("id: \(String(describing: post.id))")
                        print("web_user_id: \(String(describing: post.web_user_id))")
                        print("title_name: \(String(describing: post.titlename))")
                    }
                    
                    //アクセスできなかった場合
                } else {
                    
                    print("アクセスできませんでした")
                    
                }
                
            }
            
            //ヘッダー情報を取ってこれていなかった場合
        } else {
            
            //ログインしていないと警告を出す
            
        }
        
    }
    
    
    
    //updateアクション
    //post_idで更新する
    @IBAction func updatePostButtonClicked(_ sender: Any) {
        
        let rndstr = generate(length: 32)
        
        //パラメーターを辞書で入れていく//左辺がカラム名、右辺が値
        var params: [String: Any] = [:]
        params["title_name"] = rndstr
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            let postid: Int = Int(idTextField.text!)!
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = self.accesstoken
            headers["client"] = self.client
            headers["uid"] = self.uid
            
            print("accesstoken: \(String(describing: self.accesstoken))")
            print("client: \(String(describing: self.client))")
            print("uid: \(String(describing: self.uid))")
            
            //PUT /api/posts/:id/update_post_id(.:format)
            Alamofire.request("http://localhost:3000/api/posts/\(postid)/update_post_id", method: .put, parameters: params, headers: headers).responseJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                //型を指定した定数にいれないと比較演算子が使えない
                let res: Int = (response.response?.statusCode)!
                
                //アクセスできた場合(更新ができた場合)
                if res >= 200 && res < 300 {
                    print("通信に成功しました")
                    
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    print("Error: \(String(describing: response.error))")
                    
                    //アクセスできなかった場合
                } else {
                    
                    print("アクセスできませんでした")
                    
                }
                
            }
            
            //ヘッダー情報を取ってこれていなかった場合
        } else {
            
            //ログインしていないと警告を出す
            
        }
        
    }
    
    
    
    
    
    
    
    
    //destroyアクション
    //post_idで削除する
    @IBAction func destroyPostButtonClicked(_ sender: Any) {
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            let postid: Int = Int(idTextField.text!)!
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = self.accesstoken
            headers["client"] = self.client
            headers["uid"] = self.uid
            
            print("accesstoken: \(String(describing: self.accesstoken))")
            print("client: \(String(describing: self.client))")
            print("uid: \(String(describing: self.uid))")
            
            //DELETE /api/posts/:id(.:format)
            Alamofire.request("http://localhost:3000/api/posts/\(postid)", method: .delete, headers: headers).responseJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                
                //型を指定した定数にいれないと比較演算子が使えない
                let res: Int = (response.response?.statusCode)!
                
                //アクセスできた場合(更新ができた場合)
                if res >= 200 && res < 300 {
                    print("通信に成功しました")
                    
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    print("Error: \(String(describing: response.error))")
                    
                    //アクセスできなかった場合
                } else {
                    
                    print("アクセスできませんでした")
                    
                }
                
            }
            
            //ヘッダー情報を取ってこれていなかった場合
        } else {
            
            //ログインしていないと警告を出す
            
        }
        
    }
    
    
    
    //my_post_show_web_user_idアクション
    //自分のpostのみ取ってくる
    @IBAction func myPostShowButtonClicked(_ sender: Any) {
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            let webuserid: Int = self.webuser.web_user_id
            let accesstoken: String = self.accesstoken
            let client: String = self.client
            let uid: String = self.uid
            
            print("WebuserID: \(String(describing: webuserid))")
            print("accesstoken: \(String(describing: accesstoken))")
            print("client: \(String(describing: client))")
            print("uid: \(String(describing: uid))")
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = accesstoken
            headers["client"] = client
            headers["uid"] = uid
            
            print("requestURL_post: http://localhost:3000/api/posts/\(webuserid)/my_post_show_web_user_id.json")
            
            //GET /api/posts/:id/my_post_show_web_user_id(.:format)
            //ログインした際にとって来たトークン情報と、自分のwebuserid(アカウントID)を使って自分のpostのみを取ってくる
            Alamofire.request("http://localhost:3000/api/posts/\(webuserid)/my_post_show_web_user_id.json", method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                //アクセスできた場合
                if response.response?.statusCode == 200 {
                    
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    print("Error: \(String(describing: response.error))")
                    print("Value: \(String(describing: response.result.value))")
                    
                    self.myposts.removeAll()
                    
                    //responseからとって来たデータを抜き出す
                    let json:JSON = JSON(response.result.value ?? kill)
                    json.forEach { (arg) in
                        let (_, json) = arg
                        
                        //Postに保存
                        let post = Post()
                        
                        //パラメーターセット
                        post.id = json["id"].intValue
                        post.web_user_id = json["web_user_id"].intValue
                        post.postImage = json["post_image"]["url"].stringValue
                        post.titlename = json["title_name"].stringValue
                        
                        print("id: \(String(describing: post.id))")
                        print("web_user_id: \(String(describing: post.web_user_id))")
                        print("post_image: \(String(describing: post.postImage))")
                        print("title_name: \(String(describing: post.titlename))")
                        
                        self.myposts.append(post)
                        
                    }
                    
                    //アクセスできなかった場合
                } else {
                    
                    //アクセスできなかった場合
                    
                    print("Error: \(String(describing: response.error))")
                }
                
            }
            
            //ヘッダー情報を取ってこれていなかった場合
        } else {
            
            //ログインしていないと警告を出す
            
        }
        
    }
    
    
    
    
    
    //画像とpostのパラメーターを保存
    @IBAction func postImageSaveButton_Clicked(_ sender: AnyObject) {
        
        //画像名を作る
        postImagerandomString = generate(length: 30) as String
        //タイトルを作る
        titleNamerandomString = generate(length: 30) as String
        
        //画像を用意してね！
        let image = UIImage(named: "IMG_0002.JPG")
        let data = UIImageJPEGRepresentation(image!, 1.0)
        
        //画像を保存する関数を実行する
        self.createImage(postimagedata: data!, fileName: postImagerandomString)
        
    }
    
    
    
    //dataには画像、wihtNameには保存するカラム名、fileNameにはランダムに作った画像名を入れる
    func createImage(postimagedata: Data, fileName: String) {
        
        //ログインやサインアップでこれらの情報を取ってこれていた場合は
        if self.accesstoken != nil && self.client != nil && self.uid != nil {
            
            let accesstoken: String = self.accesstoken//optionalをStringに変換
            let client: String = self.client//optionalをStringに変換
            let uid: String = self.uid//optionalをStringに変換
            
            //取り出したトークン情報をヘッダーに格納
            var headers: [String : String] = [:]
            headers["access-token"] = accesstoken
            headers["client"] = client
            headers["uid"] = uid
            
            print("accesstoken: \(String(describing: accesstoken))")
            print("client: \(String(describing: client))")
            print("uid: \(String(describing: uid))")
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                //画像を送りたい場合はこれを使用*******************************
                //複数個指定可
                //dataにはData型でUIImageJPEGRepresentationなどでUIImageから変換する
                //withNameはサーバーで受け取る際、使用する名前。つまりはRails側のカラム名
                //fileNameはファイルの名前。
                //mimeTypeはファイルのフォーマット
                multipartFormData.append(postimagedata, withName: "post_image", fileName: "\(fileName).jpeg", mimeType: "image/jpeg")
                
                /*
                 //送りたいテキストがある場合はこれを使用*************************
                 //テキストをdata型に変換
                 if let data = "文字列".data(using: String.Encoding.utf8) {
                 //withNameはサーバーで受け取る際、使用する名前。つまりはRails側のカラム名
                 multipartFormData.append(data, withName: "name")
                 }
                 */
                
                //ここにRailsのコントローラーアクションへのルートを入れる
            }, to: "http://localhost:3000/api/posts", method: .post, headers: headers) { (encodingResult) in
                switch encodingResult {
                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                    upload.responseJSON { response in
                        //debugPrint(response)
                        print("Request: \(String(describing: response.request))")
                        print("Response: \(String(describing: response.response))")
                        print("Error: \(String(describing: response.error))")
                        
                        let json:JSON = JSON(response.result.value ?? kill)
                        
                        //保存した画像のpostのIDを取り出す。次に保存(更新)するpostデータのために必要
                        let postid = json["id"].intValue
                        print("id: \(String(describing: postid))")
                        
                        //データを保存
                        self.creatNewPost(id: postid)
                        
                    }
                case .failure(let encodingError):
                    print("エラーだよ")
                    print(encodingError)
                    
                }
            }
            
        }
    }


    
    
    
    
    //postデータを保存する関数
    func creatNewPost(id: Int) {
        
        print("画像は\(postImagerandomString)")
        print("タイトルは\(titleNamerandomString)")
        
        let accesstoken: String = self.accesstoken//optionalをStringに変換
        let client: String = self.client//optionalをStringに変換
        let uid: String = self.uid//optionalをStringに変換
        
        //取り出したトークン情報をヘッダーに格納
        var headers: [String : String] = [:]
        headers["access-token"] = accesstoken
        headers["client"] = client
        headers["uid"] = uid
        
        //パラメーターを辞書で入れていく//左辺がカラム名、右辺が値
        var params: [String: Any] = [:]
        params["web_user_id"] = self.webuser.web_user_id
        params["title_name"] = self.postImagerandomString
        //画像アップロードでcreateをしたのでデータを作成する場合はcreateしたレコードのIDにアップデートする
        
        //PUT /api/posts/:id/update_post_id(.:format)
        Alamofire.request("http://localhost:3000/api/posts/\(id)/update_post_id", method: .put, parameters: params, headers: headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            //型を指定した定数にいれないと比較演算子が使えない
            let res: Int = (response.response?.statusCode)!
            
            //アクセスできた場合(更新ができた場合)
            if res >= 200 && res < 300 {
                print("通信に成功しました")
                print("post saved")
                
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                print("Error: \(String(describing: response.error))")
                print("アップデートなので、レスポンスデータはありません")
                
                let newPost = Post()
                
                //パラメーターセット
                newPost.id = id
                newPost.web_user_id = self.webuser.web_user_id
                newPost.postImage = "https://バケット名.s3-ap-northeast-1.amazonaws.com/fog_directory(バケット)名/uploaderに定義したディレクトリー名/\(id)/\(self.postImagerandomString).jpeg"
                newPost.titlename = self.titleNamerandomString
                
                self.myposts.append(newPost)
                
                //アクセスできなかった場合
            } else {
                
                print("アクセスできませんでした")
                
            }
            
        }
        
    }

    
    
    
    
    
    //画像の取得
    @IBAction func postImagegetButton_Clicked(_ sender: AnyObject) {
        
        // タイムアウトの設定
        let TIME_OUT: TimeInterval = 1 * 300
        
        let post = myposts.last!
        
        let url: String = post.postImage
        
        print("url:\(url)")
        // URLRequestの生成
        let req = URLRequest(url: NSURL(string: url)! as URL,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: TIME_OUT)
        let conf =  URLSessionConfiguration.default
        // URLSessionの生成
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
        session.dataTask(with: req, completionHandler:
            { imageData, resp, err in
                // 通信結果
                if err == nil {
                    // Success
                    
                    self.imageView.image = UIImage(data: imageData!)!
                    self.view.addSubview(self.imageView)
                    
                }else{
                    // Error
                    
                    print("エラーです")
                    //self.imageView.image = UIImage(named: "代わりの画像画像")
                }
                
        }).resume()
        
    }
    

}
