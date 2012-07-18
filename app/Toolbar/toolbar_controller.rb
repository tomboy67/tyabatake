require 'rho/rhocontroller'
require 'rho/rhotoolbar'

class ToolbarController < Rho::RhoController

  def index
    render :back => '/app'
  end
  
  #ツールバーを削除
  def remove
    #ツールバーを削除
    Rho::NativeToolbar.remove
    $tab_active = false
    render :action => :index
  end

  #ツールバー作成
  def create_toolbar
    #オプション指定
    options = [
      #:action => アクションを指定 :icon => 表示するアイコン画像を指定                :colored_icon => 画像をカラーで表示させるかどうか
      {:action => :back,       :icon => '/public/images/toolbar/back.png',    :colored_icon => true},
      {:action => :separator},#間隔をあける
      {:action => :home,       :icon => '/public/images/toolbar/home.png',    :colored_icon => true},
      {:action => :refresh,    :icon => '/public/images/toolbar/refresh.png', :colored_icon => true},
      {:action => :options,    :icon => '/public/images/toolbar/option.png',  :colored_icon => true}
    ]
    #ツールバーを作成         (:buttons => オプション指定  :background_color => 背景を指定)
    Rho::NativeToolbar.create(:buttons => options, :background_color => 0xffffc0)
    $tab_active = false
    render :action => :index
  end
  
end
