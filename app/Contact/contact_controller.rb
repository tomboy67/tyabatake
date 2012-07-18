require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'rho/rhocontact'

# 電話帳機能サンプルコントローラ
class ContactController < Rho::RhoController
  include BrowserHelper

  PER_PAGE = 3

  # トップメニュー
  def index
    # 電話帳に登録されている件数を取得
    @count = Rho::RhoContact.find(:count)
    render :back => Rho::RhoConfig.start_path
  end

  # 一覧表示
  def list
    # 電話帳に登録されているデータをすべて取得
    @contacts = Rho::RhoContact.find(:all)
    render :back => url_for(:action => :index)
  end

  # ページネート表示
  def paginate
    page = @params["page"] ? @params["page"].to_i : 0
    offset = PER_PAGE * page
    @count = Rho::RhoContact.find(:count)

    # * :per_page - 取得するデータ件数(SQLのlimit)
    # * :offset -   データの取得開始位置
    @contacts = Rho::RhoContact.find(
      :all,
      :per_page => PER_PAGE,
      :offset => offset
    )

    @next_page = page + 1 if @count > offset + 1
    @prev_page = page - 1 if page > 0
    render :back => url_for(:action => :index)
  end

  # 検索一覧表示
  def search
    # :conditionsで指定できる値は、"is_nil"か""not_nil"のみ
    # :conditionsの指定はAndroid端末のみ利用可能
    @contacts = Rho::RhoContact.find(:all, :conditions => {"first_name" => "is_nil"})
    render :action => :list, :back => url_for(:action => :index)
  end

  # テストデータの投入
  def init
    contacts = Rho::RhoContact.find(:all, :select => ["last_name"])
    contacts.each do |c|
      Rho::RhoContact.destroy(c[1]["id"]) if c[1]["last_name"] == "sample"
    end
    
    prefix = "A"
    15.times do |n|
      attr = {"first_name" => "#{prefix}-name", "last_name" => "sample", "mobile_number" => "+123456789012"}
      Rho::RhoContact.create!(attr)
      prefix.next!
    end

    Alert.show_popup("テストデータを投入しました。")
    redirect :action => :index
  end

  # 電話帳詳細表示
  def show
    # 電話帳データをIDをもとに取得する。
    @contact = Rho::RhoContact.find(@params['id'])
    if @contact
      render :action => :show, :back => url_for(:action => :list)
    else
      redirect :action => :list
    end
  end

  # 電話帳新規作成画面
  def new
    @contact = {}
    render :action => :new, :back => url_for(:action => :index)
  end

  # 電話帳編集画面
  def edit
    @contact = Rho::RhoContact.find(@params['id'])
    if @contact
      render :action => :edit, :back => url_for(:action => :show, :id => @params["id"])
    else
      redirect :action => :index
    end
  end

  # 電話帳データ作成
  def create
    # 作成する情報をcreate!メソッドにHash形式で渡す。
    Rho::RhoContact.create!(@params['contact'])
    Alert.show_popup("作成しました。")
    redirect :action => :list
  end

  # 電話帳データ更新
  def update
    # 更新する情報をupdate_attributesメソッドにHash形式で渡す。
    # ここに修正するデータのidが含まれている必要がある。
    Rho::RhoContact.update_attributes(@params['contact'])
    Alert.show_popup("更新しました。")
    redirect :action => :show, :id => @params["contact"]["id"]
  end

  # 電話帳データ削除
  def delete
    # 削除したい電話帳データのIDを渡す。
    Alert.show_popup(
      :title => "警告",
      :icon => :alert,
      :message => "本当に削除してよろしいですか？",
      :buttons => ["OK", {:id => "cancel", :title => "キャンセル"}],
      :callback => url_for(:action => :delete_callback)
    )
    render :string => "wait..."
  end

  # 電話帳データ削除
  def delete_callback
    if @params["button_id"] == "OK"
      # 削除したい電話帳データのIDを渡す。
      Rho::RhoContact.destroy(@params['id'])
      Alert.show_popup("削除しました。")
    else
      Alert.show_popup("削除をキャンセルしました。")
    end
    # コールバック処理ではWebView.navigateを使用しないと画面が更新されない。
    WebView.navigate(url_for(:action => :list))
  end
end
