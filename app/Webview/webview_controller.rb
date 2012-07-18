require 'rho/rhocontroller'
require 'helpers/browser_helper'

class WebviewController < Rho::RhoController
  include BrowserHelper

  def index
    render :back => '/app'
  end
  
  #画面を更新させる
  def refresh
   if $tab_active
     #現在のタブの画面を更新(タブのインデックス)
     WebView.refresh(Rho::NativeTabbar.get_current_tab)
   else
     #現在の画面を更新
     WebView.refresh
   end
  end
  
  #コントローラーから画面を移動させる
  def navigate
    if $tab_active
      #現在のタブの画面を移動(移動先, タブのインデックス)
      WebView.navigate('/app', Rho::NativeTabbar.get_current_tab)
    else
      #現在の画面を移動(移動先)
      WebView.navigate('/app')
    end
  end
  
  #現在のURLを取得
  def location
    if $tab_active
      #現在のタブのURLを取得                 (タブのインデックス)
      location = WebView.current_location(Rho::NativeTabbar.get_current_tab)
    else
      #現在のページのURLを取得
      location = WebView.current_location
    end
    Alert.show_popup(location)
    render :action => :index
  end
  
  #javascriptの呼び出し
  def call_js
    #javascriptの呼び出し("関数名")
    WebView.execute_js("webalert()")
    render :action => :index
  end
  
  #タブのインデックスを取得
  def get_tab
    #現在のタブのインデックスを取得
    tab_indexs = WebView.active_tab
    Alert.show_popup(tab_indexs)
    render :action => :index
  end
  
  #フルスクリーンモード機能
  def full_screen
    #フルスクリーンモードの切り替え(1 => 有効, 0 => 無効)
    WebView.full_screen_mode(@params['mode'].to_i)
    case @params['mode']
    when "1" then
      $full_screen = true
    when "0" then
      $full_screen = false
    end
    render :action => :index
  end
end
