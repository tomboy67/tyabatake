require 'rho/rhocontroller'
require 'helpers/browser_helper'

class BarcodeController < Rho::RhoController
  include BrowserHelper

  # GET /Barcode
  def index
    render :back => '/app'
  end
  
  #バーコード読み取り機能
  def take_barcode
    #バーコードを読み取る(コールバックを指定)
    Barcode.take_barcode(url_for(:action => :barcode_callback), {})
    redirect :action => :index
  end
  
  #コールバック
  def barcode_callback
    if @params['status'] == 'ok'
      #読み取ったバーコードをポップアップで表示
      Alert.show_popup(@params['barcode'])
    end
    #コールバックが終了したら画面を移動
    WebView.navigate(url_for(:action => :index))
  end
end
