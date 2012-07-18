require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'

class ImageController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper
  
  #カメラ撮影機能トップ画面
  def index
    @images = Image.find(:all)
    
    #メインカメラの情報を取得
    main_camera = Camera::get_camera_info('main')
    if main_camera
      #メインカメラの解像度(横・縦)を取得
      @camera_main = main_camera['max_resolution']['width'].to_s + 'x' + main_camera['max_resolution']['height'].to_s
    else
      @camera_main = "存在しません"
    end
    
    #前面カメラの情報を取得
    front_camera = Camera::get_camera_info('front')
    if front_camera
      #前面カメラの解像度(横・縦)を取得
      @camera_front = front_camera['max_resolution']['width'].to_s + 'x' + front_camera['max_resolution']['height'].to_s
    else
      @camera_front = "存在しません"
    end

    render :back => '/app'
  end
  
  def on_take
    ed = (@params['enable_editing'] == 'enable')
    size = @params['preferred_size']
    case size
      when 'one'
        width, height = 1000, 1000
      when 'two'
        width, height = 100, 100
      when 'three'
        width, height = 640, 480
    end
    settings = {:camera_type    => @params['camera_type'], #カメラのタイプを指定 : "main" ➡ メインカメラ, "front" ➡ 前面カメラ 
                :color_model    => @params['color_model'], #撮影時の色指定 : "RGB" ➡ カラー, "Grayscale" =➡ 白黒
                :format         => @params['format'],      #画像の形式指定 : "jpg" ➡ jpg形式, "png" ➡ png形式
                :desired_width  => width,                  #画像横サイズの指定(初期値はカメラの最大横幅)
                :desired_height => height,                 #画像縦サイズの指定(初期値はカメラの最大縦幅) 
                :enable_editing => ed,                     #編集モードの有無(iOSのみ) : true ➡ 有効, false ➡ 無効
                :flash_mode     => @params['flash']}       #フラッシュの指定(androidのみ) : "off", "on", "auto", "red-eye", "torch"
    #カメラの起動・コールバックの呼び出し
    Camera::take_picture(url_for(:action => :camera_callback), settings)
    redirect :action => :index
  end
  
  def choose_picture
    #画像選択画面起動・コールバックの呼び出し
    Camera::choose_picture(url_for(:action => :camera_callback))
    redirect :action => :index
  end
  
  def camera_callback
    if @params['status'] == 'ok'
      Image.create({'image_uri' => @params['image_uri']})
    end
    #強制的な画面遷移(コールバックの処理が終わったタイミングで画面が切り替わらないため)
    WebView.navigate(url_for(:action => :index))
  end
  
  def destroy
    @image = Image.find(@params['id'])
    @image.destroy
    redirect :action => :index
  end
end
