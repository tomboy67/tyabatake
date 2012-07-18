require 'rho/rhocontroller'
require 'helpers/browser_helper'

class NavbarController < Rho::RhoController
  include BrowserHelper

  # GET /Navbar
  def index
    render :back => '/app'
  end
  
  #ナビゲーションバーを作成
  def create_navbar
                  #タイトルを指定(中央に配置される)
    NavBar.create(:title => "ナビゲーションバー",
                  #左側に配置するアクションを指定する   
                  :left => {
                    :action => :back, #アクション名
                    :label => "戻る"   #表示する文字
                  },
                  #右側に配置するアクションを指定する
                  :right => {
                    :action => :refresh,
                    :label => "更新"
                  }
                  )
    render :action => :index
  end
  
  #ナビゲーションバーを削除
  def remove_navbar
    #ナビゲーションバーを削除
    NavBar.remove
    render :action => :index
  end
  
end
