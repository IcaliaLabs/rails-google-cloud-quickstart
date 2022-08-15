# frozen_string_literal: true

#= EnablePgcryptoExtension
#
# Used as a the first migration to have something to generate a database on an
# empty project...
class EnablePgcryptoExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
