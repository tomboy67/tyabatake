require 'rho/rhocontroller'
require 'helpers/browser_helper'

# 着信音機能
class RingtonesController < Rho::RhoController
  include BrowserHelper

  # 着信音一覧
  def index
    # 着信音を再生中の場合、停止する。
    Rho::RingtoneManager::stop
    # 端末に保存されている着信音をすべて取得
    @ringtones = Rho::RingtoneManager::get_all_ringtones
    @ringtones = [] if @ringtones.nil?
    render :back => Rho::RhoConfig.start_path
  end

  # 着信音を再生する。
  def play_ringtone
    @name = @params["name"]
    # 選択した着信音を再生する。
    Rho::RingtoneManager::play(@params["file"])
    render :back => url_for(:action => :index)
  end
end
