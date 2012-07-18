require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rho/rhobluetooth'

class BluetoothController < Rho::RhoController
  include BrowserHelper
  layout 'Bluetooth/layout'

  $status = "接続されていません"

  #Bluetooth機能のトップページ
  def index
    #デバイスの名前を取得
    @device_name = Rho::BluetoothManager.get_device_name
    #デバイスがBluetoothを使用可能かどうかを調べる
    @available = Rho::BluetoothManager.is_bluetooth_available
    #最後に発生したエラーを取得する
    @error = Rho::BluetoothManager.get_last_error
    render :back => '/app'
  end

  #Bluetooth機能をオフにする
  def off
    #Bluetoothの機能をオフにする
    Rho::BluetoothManager.off_bluetooth
    redirect :action => :index
  end

  #端末の名前を変更する
  def set_name
    #端末の名前を変更する
    Rho::BluetoothManager.set_device_name(@params['name'])
    redirect :action => :index
  end

  #サーバとしてセッションを開始する
  def create_server_session
    #端末を公開する(サーバとして使用)・コールバックの設定
    Rho::BluetoothManager.create_session(Rho::BluetoothManager::ROLE_SERVER, url_for(:action => :create_callback))
    redirect :action => :index
  end

  #クライアントとしてセッションを開始する
  def create_client_session
    #端末を他の端末に接続(クライアントとして使用)・コールバックの設定
    Rho::BluetoothManager.create_session(Rho::BluetoothManager::ROLE_CLIENT, url_for(:action => :create_callback) )
    render :action => :wait
  end

  #他の端末に接続する
  def connect_to_device
    #デバイスの名前を指定して、接続をする
    Rho::BluetoothManager.create_client_connection_to_device(@params['server_name'], url_for(:action => :create_callback))
  end

  #サーバを公開して接続を待つ
  def server_wait
    #端末を公開して他の端末からの接続を待つ
    Rho::BluetoothManager.create_server_and_wait_for_connection(url_for(:action => :create_callback))
  end

  #メッセージを送信する
  def send_message
    #接続している端末に文字列を送信する
    Rho::BluetoothSession.write_string($device_name, @params['message'])
    #送信する文字列の整形
    message = Rho::BluetoothManager.get_device_name + ':' + @params['message'] + '\n'
    WebView.execute_js('Write("' + message + '");')
  end


  #セッション作成時のコールバック
  def create_callback
    #接続しているデバイス名をグローバル変数に保存
    $device_name = @params['connected_device_name']
    #接続結果により処理を分ける
    case @params['status']
    #接続が成功
    when "OK"
      $status = $device_name + 'さんと接続しました'
      Alert.show_popup({:message => "#{$device_name}との接続に成功しました", :title => "結果", :buttons => ["閉じる"]})
      #セッションのコールバックを設定(他の端末からの通信を受け取ると入る)
      Rho::BluetoothSession.set_callback($device_name, url_for(:action => :session_callback))
      #接続先の相手に、初期メッセージを送信
      Rho::BluetoothSession.write_string($device_name, "こんにちは#{$device_name}さん")
    #接続がキャンセル
    when "CANCEL"
      $status = "接続されていません"
      Alert.show_popup({:message => "接続をキャンセルしました", :title => "結果", :buttons => ["閉じる"]})
    #接続がエラー
    when "ERROR"
      $status = "接続されていません"
      Alert.show_popup({:message => "接続に失敗しました", :title => "結果", :buttons => ["閉じる"]})
    end
    WebView.navigate(url_for(:action => :index))
  end

  #セッションのコールバック
  def session_callback
    #受け取ったイベントのタイプによって処理を分ける
    case @params['event_type']
    #データを受け取った場合
    when Rho::BluetoothSession::SESSION_INPUT_DATA_RECEIVED
      #データサイズが0以上の間処理を続ける(-1 => エラー, 0 => 何もデータを受け取ってない)jj
      while Rho::BluetoothSession.get_status($device_name) > 0
        #接続先の端末から受け取ったメッセージを取得
        message = Rho::BluetoothSession.read_string(@params['connected_device_name'])
        #受け取ったメッセージの整形
        message = @params['connected_device_name'] + ':' + message + '\n'
        WebView.execute_js('Write("'+message+'");')
      end
    #エラーを受け取った場合
    when Rho::BluetoothSession::ERROR
      $status = "接続されていません"
      Alert.show_popup({:message => "接続が切れました", :title => "結果", :buttons => ["閉じる"]})
    #接続が切断された場合
    when Rho::BluetoothSession::SESSION_DISCONNECT
      $status = "接続されていません"
      Alert.show_popup({:message => "接続がキャンセル", :title => "結果", :buttons => ["閉じる"]})
    end
  end

  #Bluetooth接続を切断する
  def disconnect
    #接続を終了する
    Rho::BluetoothSession.disconnect($device_name)
  end
end

