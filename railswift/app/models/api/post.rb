class Api::Post < ApplicationRecord

  # どのカラムにどのアップローダーを使うか
  # Postのpost_imageカラムに対して、アップローダーのImageUploaderの設定でアップする
  mount_uploader :post_image, ImageUploader

  # S3の画像を削除
  before_destroy :clean_s3

  private
  # S3の画像を削除
  def clean_s3
    image.remove!       #オリジナルの画像を削除
    image.thumb.remove! #thumb画像を削除
  rescue Excon::Errors::Error => error
    puts "Something gone wrong"
    false
  end
end