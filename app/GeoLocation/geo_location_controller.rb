require 'rho/rhocontroller'
require 'helpers/browser_helper'

class GeoLocationController < Rho::RhoController
  include BrowserHelper

  #Google Maps Api を取得して表示
  def show_google
    #緯度の取得
    @lat = GeoLocation.latitude
    #経度の取得
    @lng = GeoLocation.longitude
    if System::get_property('platform') == 'Blackberry'
      set_geoview_notification(url_for(:action => :geo_callback), "", 5)
    else
      #5秒ごとに位置情報をバックグラウンドで取得し、コールバックに入る
      GeoLocation.set_notification(url_for(:action => :geo_callback), "", 5)
    end
    render :layout => 'GeoLocation/layout'
  end

  #現在地を取得してjavascriptを呼び出し
  def geo_callback
    #現在のページがGPS機能でない場合
    if WebView.current_location !~ /GeoLocation/
      #位置情報の取得をストップ
      GeoLocation.turnoff
      return
    end

    #位置情報の取得に成功し、現在地が分かっている場合
    if @params['status'] =='ok'  && @params['known_position'] ==  "1"
      if System::get_property('platform') == 'Blackberry'
        WebView.refresh
      else
        #コントラーラーから直接java script(public/js/map.js内)の呼び出し
        WebView.execute_js("SetLocation(#{@params['latitude']}, #{@params['longitude']})")
      end
    end
  end

  #RhoMapを使用し、現在地を取得し2点間の距離を計算
  def show_rhomap
   #緯度の取得
   lat = GeoLocation.latitude
   #経度の取得
   lng = GeoLocation.longitude
   #現在地から「東京スカイツリー」までの距離を計算してマイルからキロメーターに変換
   @dis = GeoLocation.haversine_distance(lat, lng, 35.710058, 139.810718) * 1.6093
  end

  #MapViewの呼び出し
  def map_view
    #緯度の取得
    lat = GeoLocation.latitude
    #経度の取得
    lng = GeoLocation.longitude
    map_params = {
                   #地図のプロバイダーを指定: "Google", "RhoGoogle", "ESRI", "OSM"
                   :provider => @params['provider'],
                                 #マップの種類を指定: "standard" => 標準, "satellite" => 衛生, "hybrid" => 標準 + 衛生
                   :settings => {:map_type              => @params['map_type'],
                                 #マップの表示場所指定         [経度, 緯度, 緯度デルタ, 経度デルタ]
                                 :region                => [lat.to_s, lng.to_s, 0.2, 0.2],
                                 #マップのズーム機能           ture, false
                                 :zoom_enabled          => true,
                                 #マップのスクロール機能        true, false
                                 :scroll_enabled        => true,
                                 #自分の現在地表示             true, false
                                 :shows_user_location   => false,
                                 #Google maps api キー
                                 :api_key               => '0XsHtpTZ1qKKDHzAZXLfFz5J9GsJ3ucPINQvRoA'},
                                 #マップ上の注釈の設定
                                 :annotations => [{
                                                    #注釈を表示する緯度
                                                    :latitude   => lat,
                                                    #注釈を表示する経度
                                                    :longitude  => lng,
                                                    #注釈のタイトル
                                                    :title      => 'あなたの現在地'}]
                 }
     #マップを表示
     MapView.create map_params
     redirect :action => :show_rhomap
  end

end
