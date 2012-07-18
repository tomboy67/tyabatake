require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'nfc'

class NfcController < Rho::RhoController
  include BrowserHelper
  layout 'Nfc/layout'

  #Nfc機能トップページ
  def index
    #端末がNfc機能に対応しているかどうか
    @support = Rho::NFCManager.is_supported
    #一度Nfc機能をオフにする。(Nfc機能を使用した後に、オフにしなければバックグラウンドでコールバックが動き続けるため)
    Rho::NFCManager.disable
    render :back => '/app'
  end

  #Nfcリーダー機能
  def read
    #Nfc機能をオンにする
    Rho::NFCManager.enable
    #Nfc機能がオンになったかどうか(true or false)
    @status = Rho::NFCManager.is_enabled
    #Nfcを読み込んだ時のコールバックを設定(Nfcを読み込むと、指定したコールバックへ自動的に入る)
    Rho::NFCManager.set_nfc_tech_callback(url_for(:action => :nfc_tech_callback))
    render :back => '/app'
  end

  #nfcテクノロジーをキャッチしたら入る
  def nfc_tech_callback
    WebView.execute_js("clear();")
    #現在のタグの取得
    tag = Rho::NFCManager.get_current_Tag
    #タグからIDmを取得
    idm = tag.get_ID
    #テクノロジーのリストを取得(Type Of Array  ex. ["NdeF", "NfcF"])
    t_tech_list = tag.get_tech_list
    WebView.execute_js("id('#{idm.inspect}');")
    WebView.execute_js("tech('#{t_tech_list.inspect}');")
    #テクノロジーごとの読み込みメソッドを呼び出し
    t_tech_list.each do |tech|
      #テクノロジーリストからテクノロジー名(String)を取り出し、文字列('tag')を連結させ、小文字にする(ex. "NfcF" => "nfcf(tag)")
      tech = (tech += '(tag)').downcase
      #メソッドの呼び出し(＊evalメソッド => "文字列をRubyのスクリプトと見なし実行する  *ex. "nfcf(tag)" => nfcf(tag))
      eval(tech)
    end
  end

  #Ndefタグを取得する
  def ndef(tag)
    #タグからNdefメッセージのインスタンスを読み込む
    ndef = tag.get_tech(Rho::NFCTagTechnology::NDEF)
    #Ndefメッセージを読み込めたかどうか
    if ndef
      #Ndefタグに接続する
      ndef.connect
      #Ndefタグを読み込むメソッドの呼び出し(下部に記載)
      read_ndef(ndef)   #:read_ndef => :read_message => read_records and return
      #Ndefタグの接続を切断する。
      ndef.close
    end
  end

  #Ndefタグを読み込む(◯呼び出し元 => :nfc_tech_callback)
  def read_ndef(ndef)
    #ndefタグのNfcフォーラムが定めるタイプを取得
    type = ndef.get_type
    #ndefタグの最大サイズを取得
    max_size = ndef.get_max_size
    #ndefタグに書き込み可能かどうか(true or false)
    writable = ndef.is_writable
    #Ndefタグに読み込み専用オプションをつけれるかどうか(true or false)
    readonly = ndef.can_make_read_only
    WebView.execute_js("type('#{type.inspect}');")
    WebView.execute_js("max_size('#{max_size.inspect}バイト');")
    WebView.execute_js("writable('#{writable.inspect}');")
    WebView.execute_js("readonly('#{readonly.inspect}');")
    #NdefMessageを読み込むメソッドの呼び出し
    read_message(ndef)
  end

  #NdefMessageを読み込むメソッド(◯呼び出し元 => :read_ndef)
  def read_message(ndef)
    #NdefタグからNdefMessageを読み込む
    ndef_message = ndef.read_NdefMessage
    #NdefMessageのバイトコードを取得する
    byte_code = ndef_message.get_byte_array
    WebView.execute_js("message_byte('#{byte_code.inspect}');")
    #ndefのレコードを読み込むメソッドの呼び出し
    read_records(ndef_message)
  end

  #レコードを読み込むメソッド(◯呼び出し元 => :read_message)
  def read_records(ndef_message)
    #NdefMessageからレコードの取得(Array)
    records = ndef_message.get_records
    #レコードを一つずつとりだす
    records.each do |record|
      #レコードのpayload-stringを取り出す
      payload_s  = record.get_payload_as_string
      #レコードのTNFを取り出す(Integer)
      tnf = record.get_tnf
      #TNFの数字を文字列に変換
      tnf_string = Rho::NdefRecord.convert_Tnf_to_string(tnf)
      #レコードのRTDを取り出す(Integer)
      rtd = record.get_type
      #rtdの数字を文字列に変換
      rtd_string = Rho::NdefRecord.convert_RTD_to_string(rtd)
      WebView.execute_js("payload('#{payload_s.inspect}');")
      WebView.execute_js("tnf('#{tnf_string.inspect}');")
      WebView.execute_js("rtd('#{rtd_string.inspect}');")
      Alert.show_popup( {
          :message => "タグの読み込みが終わりました",
          :title => "結果",
          :buttons => ["結果を見る"]}
      )
    end
  end

  #NfcFを読み込む
  def nfcf(tag)
    #タグからNfcFのインスタンスを読み込む
    nfcf = tag.get_tech(Rho::NFCTagTechnology::NFCF)
    #NfcFから製造業者IDを取得
    manufacturer_byte = nfcf.get_manufacturer
    #NfcFからシステムコードを取得する。
    system_code = nfcf.get_system_code
    WebView.execute_js("manufacturer('#{manufacturer_byte.inspect}');")
    WebView.execute_js("system('#{system_code.inspect}');")
  end
  #リーダー機能終了-----------------------------------------------------------------------------------------

  #ライター機能--------------------------------------------------------------------------------------------
  def write
    #一度Nfc機能をオフにする。(Nfc機能を使用した後に、オフにしなければバックグラウンドでコールバックが動き続けるため)
    Rho::NFCManager.disable
    render :back => '/app/Nfc/index'
  end

  #タグの書き込みを行うコールバックを設定
  def writing
    #Nfc機能をオンにする
    Rho::NFCManager.enable
    #Nfcテクノロジーをキャッチした時に入るコールバックを設定
    Rho::NFCManager.set_nfc_tech_callback(url_for(:action => :nfc_write_callback,
                                                  :query => {
                                                    :text => (@params['type'] + @params['text']),
                                                    :tnf => @params['tnf'],
                                                    :rtd => @params['rtd'],
                                                    }
                                                 )
                                          )
    render :back => '/app/Nfc/write'
  end

  #タグの書き込みをおこなう
  def nfc_write_callback
    #現在のタグを取得
    tag = Rho::NFCManager.get_current_Tag
    #タグからNdefメッセージのインスタンスを読み込む
    ndef = tag.get_tech(Rho::NFCTagTechnology::NDEF)
    if ndef
      #ndefタグへ接続する
      ndef.connect
      #ndefメッセージを作成する自作メソッドを呼び出す(text, rtd, tnf)
      msg = msg_create(@params['text'], @params['rtd'], @params['tnf'])
      #タグを書き込む
      ndef.write_NdefMessage(msg)
      Alert.show_popup( {
          :message => "タグの書き込みが終わりました",
          :title => "結果",
          :buttons => ["閉じる"]}
      )
      #ndefタグへの接続を切断する
      ndef.close
    else
      Alert.show_popup( {
        :message => "タグを書き込めませんでした",
        :title => "結果",
        :buttons => ["閉じる"]}
      )
    end
    WebView.navigate(url_for(:action => :index))
  end

  #NdefMessageを作成する
  def msg_create(text, rtd, tnf)
    #rtdの種類によって、書き込む種類を変更する
    if rtd == '84'
      #テキスト情報の作成
      payload = Rho::NFCManager.make_payload_with_well_known_text('ja', text)
    elsif rtd == '85'
      #URI情報の作成
      payload = Rho::NFCManager.make_payload_with_well_known_uri(0, text)
    end
    #type, tnf, payloadをハッシュ形式で作成
    hash = {
            'id'      => [0],
            'type'    => [rtd.to_i],
            'tnf'     => tnf.to_i,
            'payload' => payload
          }
    #ハッシュからレコードを作成
    records = [Rho::NFCManager.make_NdefRecord_from_hash(hash)]
    #レコードからNdefMessageを作成し、コールバック(:nfc_write_callback)へ値を返す
    return Rho::NFCManager.make_NdefMessage_from_array_of_NdefRecord(records)
  end
  #ライター機能終了------------------------------------------------------------------------------------------

  #p2p機能------------------------------------------------------------------------------------------------
  #ピアツーピアトップページ
  def peer_to_peer
    render :back => '/app/Nfc/index'
  end

  #タグ情報を送信する
  def push_nfc
    #Nfc機能をオンにする
    Rho::NFCManager.enable
    #ndefメッセージを作成する自作メソッドを呼び出す(text, rtd, tnf)
    msg = msg_create(@params['string'], '84', 1)
    #P2Pでタグを送信する。(バックグラウンドで動き続ける)
    Rho::NFCManager.p2p_enable_foreground_nde_push(msg)
    render :back => '/app/Nfc/stop_nfc'
  end

  #P2Pの停止
  def stop_nfc
    #P2P通信を終了させる
    Rho::NFCManager.p2p_disable_foreground_nde_push
    render :action => :peer_to_peer, :back => '/app/Nfc/index'
  end
  #p2p機能終了---------------------------------------------------------------------------------------------
end
