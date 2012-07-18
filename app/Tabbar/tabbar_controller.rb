require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rho/rhotabbar'

class TabbarController < Rho::RhoController
  include BrowserHelper

  def index
    render :back => '/app'
  end
  
  #タブバーを作成
  def create_tabbar
    #オプションを指定
    options = [
      #:label => 各タブのラベル  :action => 各タブを最初に開いた時のアクション  :icon => 各タブに表示させるアイコン  :reload => 各タブを選んだとき現在のページを再読み込みさせるかどうか :selected_color => 各タブを選んだ時の色  :web_bkg_color => タブを最初に読み込む時に表示させる色
      {:label => 'タブ1', :action => '/app/Tabbar', :icon => '/public/images/toolbar/option.png', :reload => true, :selected_color => 0xFF0000, :web_bkg_color => 0xFF0000},
      {:label => 'タブ2',  :action => '/app', :icon => '/public/images/toolbar/home.png', :reload => false, :selected_color => 0xff8000, :web_bkg_color => 0xff8000},
      {:label => 'タブ3', :action => 'callback:' + url_for(:action => :main_page), :icon => '/public/images/toolbar/window.png', :reload => false, :selected_color => 0xf0f000, :web_bkg_color => 0xf0f000}
    ]
    if @params['tab_type'] == 'ipad'
      #iPad用のタブバーを作成(:tabs => オプション指定)
      Rho::NativeTabbar.create_vertical(:tabs => options)
    else
      #タブバーを作成(:tabs => オプション指定, :place_tabs_bottom => タブを下に表示させるかどうか, :background_color => タブバーの背景を指定)
      Rho::NativeTabbar.create(:tabs => options, :place_tabs_bottom => @params['bottom'], :background_color => 0xffffc0)
      #タブにバッジを作成(タブのインデックス, 表示させる文字)
      Rho::NativeTabbar.set_tab_badge( 1, '12')
    end
    $tab_active = true
  end
  
  #タブバーを削除
  def remove_tabbar
    $tab_active = false
    #タブバーを削除
    Rho::NativeTabbar.remove
    render :action => :index
  end
  
  #タブのインデックスを取得
  def tab_index
    #現在のタブのインデックスを取得
    index = Rho::NativeTabbar.get_current_tab
    #現在のタブのインデックスをアラートで表示
    Alert.show_popup("現在のタブのインデックス#{index}")
    render :action => :index
  end
  
  #タブの切り替え
  def switch_tab
    index = strip_braces(@params['id'])
    #指定されたタブへ移動(インデックス番号)
    Rho::NativeTabbar.switch_tab(index.to_i)
    render :action => :index
  end
  
  #機能リストへ移動
  def main_page
    WebView.navigate('/app')
  end
end
