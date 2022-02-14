defmodule ExPhoneNumber.Constants.PhoneNumberTypes do
  @moduledoc false

  def fixed_line(), do: :fixed_line

  def mobile(), do: :mobile

  def fixed_line_or_mobile(), do: :fixed_line_or_mobile

  def toll_free(), do: :toll_free

  def premium_rate(), do: :premium_rate

  def shared_cost(), do: :shared_cost

  def voip(), do: :voip

  def personal_number(), do: :personal_number

  def pager(), do: :pager

  def uan(), do: :uan

  def voicemail(), do: :voicemail

  def unknown(), do: :unknown
end
