# frozen_string_literal: true

class EnablePgcryptoExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
