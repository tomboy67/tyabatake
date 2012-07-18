require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/application_helper'
require 'rho/rhoevent'
require 'rho/rhocontact'
require 'time'

# Rho::RhoEventを使用したカレンダー機能
class EventController < Rho::RhoController
  include BrowserHelper
  include ApplicationHelper

  # メニュー画面
  def index
    render :back => Rho::RhoConfig.start_path
  end

  # 一覧表示
  def list
    # index画面のフォームで入力した値をもとに、
    # スケジュールの検索を行う。
    start_date = blank?(@params["start_date"]) ? (Rho::RhoEvent::MIN_TIME + 1) : Time.parse(@params["start_date"])
    end_date = blank?(@params["end_date"]) ? (Rho::RhoEvent::MAX_TIME - 1) : Time.parse(@params["end_date"])
    include_repeating = !blank?(@params["repeating"])
    # === options
    # :all::                全件取得
    # :start_date::         開始日
    # :end_date::           終了日
    # :find_type::          検索種類(方法)
    # :include_repeating::  繰り返しのイベントを取得するか(true or false)
    #
    # ==== :find_typeに指定できる値
    # 'starting'::  :start_dateと:end_dateで指定した日付間に開始したイベントを取得します。
    # 'ending'::    :start_dateと:end_dateで指定した日付間に終了したイベントを取得します。
    # 'occurring':: :start_dateと:end_dateで指定した日付間に生じるのイベントを取得します。
    @events = Rho::RhoEvent.find(
      :all,
      :start_date => start_date,
      :end_date => end_date,
      :find_type => @params["find_type"],
      :include_repeating => include_repeating
    )

    render :back => url_for(:action => :index)
  end

  # データ投入
  def init
    events = Rho::RhoEvent.find(
      :all,
      :start_date => (Rho::RhoEvent::MIN_TIME + 1),
      :end_date => (Rho::RhoEvent::MAX_TIME - 1),
      :find_type => 'starting',
      :include_repeating => true
    )
    events.each do |c|
      Rho::RhoEvent.destroy(c[Rho::RhoEvent::ID]) if c["notes"] == "tyabatake sample"
    end

    prefix = "A"
    time = Time.now
    day = (60 * 60 * 24)
    month = (60 * 60 * 24 * 30)
    [true, false].each do |bool|
      5.times do |n|
        attr = {
          Rho::RhoEvent::TITLE      => "#{prefix}-title",
          Rho::RhoEvent::LOCATION   => "島根県松江市西津田３丁目",
          Rho::RhoEvent::NOTES      => "tyabatake sample",
          Rho::RhoEvent::START_DATE => time + (n * day),
          Rho::RhoEvent::END_DATE   => time + 1 + (n * day)
        }
        if bool
          # 繰り返しにする。
          attr.merge!(
            Rho::RhoEvent::RECURRENCE => {
              Rho::RhoEvent::RECURRENCE_FREQUENCY => Rho::RhoEvent::RECURRENCE_FREQUENCY_DAILY,
              Rho::RhoEvent::RECURRENCE_INTERVAL  => 2,
              Rho::RhoEvent::RECURRENCE_END       => time + (n * month)
            }
          )
        end
        Rho::RhoEvent.create!(attr)
        prefix.next!
      end
    end

    Alert.show_popup("テストデータを投入しました。")
    redirect :action => :index
  end

  # イベント詳細表示
  def show
    # @params['id']をもとに、スケジュールを取得する。
    @event = Rho::RhoEvent.find(@params['id'])
    if @event
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # イベント作成画面
  def new
    @event = {}
    @contacts = Rho::RhoContact.find(:all)
    render :action => :new, :back => url_for(:action => :index)
  end

  # イベント編集画面
  def edit
    @event = Rho::RhoEvent.find(@params['id'])
    @contacts = Rho::RhoContact.find(:all)
    if @event
      render :action => :edit, :back => url_for(:action => :show, :id => @params[Rho::RhoEvent::ID])
    else
      redirect :action => :index
    end
  end

  # イベント作成画面
  def create
    attributes = @params["event"]
    frequency = @params['event'][Rho::RhoEvent::RECURRENCE][Rho::RhoEvent::RECURRENCE_FREQUENCY]
    if blank?(frequency)
      # 繰り返し「なし」を選択している場合、
      # パラメータで送られた値から、繰り返し(recurrence)に関する値を削除する。
      attributes.delete(Rho::RhoEvent::RECURRENCE)
    end
    # Rho::RhoEvent.create!メソッドで
    # スケジュールを新規作成する。
    @event = Rho::RhoEvent.create!(attributes)
    Alert.show_popup("作成しました。")
    redirect :action => :index
  end

  # イベント更新処理
  def update
    attributes = @params["event"]
    frequency = @params['event'][Rho::RhoEvent::RECURRENCE][Rho::RhoEvent::RECURRENCE_FREQUENCY]
    if blank?(frequency)
      # 繰り返し「なし」を選択している場合、
      # パラメータで送られた値から、繰り返し(recurrence)に関する値を削除する。
      attributes.delete(Rho::RhoEvent::RECURRENCE)
    end
    # Rho::RhoEvent.update_attributesメソッドで
    # スケジュールを更新する。
    @event = Rho::RhoEvent.update_attributes(attributes)
    Alert.show_popup("更新しました。")
    redirect :action => :show, :id => @params['event'][Rho::RhoEvent::ID]
  end

  # イベント削除
  def delete
    # Rho::RhoEvent.destroyメソッドで
    # 指定したスケジュールを削除する。
    @event = Rho::RhoEvent.destroy(@params[Rho::RhoEvent::ID])
    Alert.show_popup("削除しました。")
    redirect :action => :index
  end

  # DateTimePickerを起動する
  def choose_date
    # DateTimePicker.choose(callback_url, title, initial_time, format, opaque)
    # ==== Args
    # * callback_url  :: DateTimePickerで日付を入力した後のコールバック先
    # * title         :: DateTimePickerのタイトル
    # * initial_time  :: 初期値（Timeオブジェクト)
    # * format        :: 日付のフォーマット
    # * <tt>0</tt>    :: 日付と時刻
    # * <tt>1</tt>    :: 日付のみ
    # * <tt>2</tt>    :: 時刻のみ
    # * opaque        :: コールバック先へ渡す文字列。指定する値はMarshal.dumpする必要がある。
    DateTimePicker.choose(url_for(:action => :choose_date_callback), @params['title'], Time.new, 0, Marshal.dump(@params['field_key']))
  end

  # DateTimePickerのコールバック
  def choose_date_callback
    if @params['status'] == 'ok'
      # DateTimePicker.chooseでMarshal.dumpした値をロードする。
      key = Marshal.load(@params['opaque'])
      result = Time.at(@params['result'].to_i).strftime('%F %T')
      # 画面上のsetFieldValueのJavascriptの関数を呼び出す。
      WebView.execute_js('setFieldValue("'+key+'","'+result+'");')
    end
  end
end
