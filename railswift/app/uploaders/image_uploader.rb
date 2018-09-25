class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # リサイズしたり画像形式を変更するのに必要
  include CarrierWave::RMagick# コメントを外す
  # include CarrierWave::MiniMagick

  # ストレージの設定
  # storage :file# コメント
  # storage :fog# コメントを外す
  if Rails.env.development?# 開発環境だった場合
    storage :fog# 開発が終わったらfileに戻す
  elsif Rails.env.test?# テスト環境だった場合
    storage :file
  else# それ以外の環境だった場合
    storage :fog
  end

  # iPhoneから画像投稿した際に、画像の向きがおかしい場合があるので、
  # Rmagickのauto_orientメソッドで向きを正す。
  process :fix_rotate
  def fix_rotate
    manipulate! do |img|
      img = img.auto_orient
      img = yield(img) if block_given?
      img
    end
  end

  # S3のディレクトリ名(フォルダー名)# 格納するディレクトリを指定
  def store_dir
    # #{}で文字列挿入
    # "uploads/#①{model.class.to_s.underscore}/#②{mounted_as}/#③{model.id}"# uploads/①モデル名/②カラム名/③モデルID
    "ディレクトリ名/#{model.id}"
    # "#{model.id}"# コメント
  end

  # キャッシュを格納ディレクトリを指定
  # def cache_dir
  #   "cache"
  # end

  # デフォルト画像は1200x5000に収まるようリサイズ
  process resize_to_limit: [1200, 5000]

  # サムネイル画像だった場合
  # version :thumb do
  #   process resize_to_fill: [100, 100]
  # end

  # 許可する画像の拡張子
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  # 保存するファイルの命名規則。上のディレクトリー+このファイル名で保存される
  def filename
    # 下のトークンを作成するメソッドでファイル名を作るパターンのコード
    # "#{secure_token(10)}.#{file.extension}" if original_filename.present?
    original_filename if original_filename# 送られて来たファイル名をダイレクトに使う
  end

  # 一意となるトークンを作成。特に使わないかも
  # ファイル名で使うメソッド
  # protected
  # def secure_token(length=16)
  #   var = :"@#{mounted_as}_secure_token"
  #   model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  # end
end