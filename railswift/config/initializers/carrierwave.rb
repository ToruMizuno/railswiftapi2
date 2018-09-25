CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    #AWSに保存するために必要
    # IAMの設定
    # アクセスキー
    # シークレットアクセスキー
    provider:              'AWS',
    # アクセスキー
    aws_access_key_id:     'アクセスキー',
    # シークレットキー
    aws_secret_access_key: 'シークレットキー',
    # Tokyo
    region:                'ap-northeast-1'
    # host: 's3.example.com',
    # endpoint: 'https://s3.example.com:8080'
  }

  # 公開・非公開の切り替え# S3のURLに直アクセスしていいか
  config.fog_public     = true

  # キャッシュをS3に保存
  # config.cache_storage = :fog
  # キャッシュの保存期間(1年)
  # config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" }
  # キャッシュの保存場所
  # config.cache_dir = 'tmp/image-cache'

  # S3のURLに有効期限を60秒で設定する
  # config.fog_authenticated_url_expiration = 60

  # S3バケットを指定
  # config.fog_directory  = 'BUCKET_NAME(ENV)'


  # 環境ごとにS3のバケットを指定
  # 
  # 保存先URL
  # asset_host名/fog_directory(バケット)名/uploaderに定義したディレクトリー名/postID/送られてくるファイル名
  case Rails.env
    when 'production'
      config.fog_directory = 'バケット名'# バケット名
      config.asset_host = 'https://バケット名.s3-ap-northeast-1.amazonaws.com'
      
    when 'development'
      config.fog_directory = 'バケット名'# バケット名
      config.asset_host = 'https://バケット名.s3-ap-northeast-1.amazonaws.com'

    when 'test'
      config.fog_directory = 'バケット名'# バケット名
      config.asset_host = 'https://バケット名.s3-ap-northeast-1.amazonaws.com'
  end
end

# 日本語ファイル名の設定# 日本語入力を可能にするため。
CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/