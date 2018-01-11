defmodule ExPhoneNumber.Constants.PhoneNumberTypes do
  @fixed_line :fixed_line
  def fixed_line(), do: @fixed_line

  @mobile :mobile
  def mobile(), do: @mobile

  @fixed_line_or_mobile :fixed_line_or_mobile
  def fixed_line_or_mobile(), do: @fixed_line_or_mobile

  @toll_free :toll_free
  def toll_free(), do: @toll_free

  @premium_rate :premium_rate
  def premium_rate(), do: @premium_rate

  @shared_cost :shared_cost
  def shared_cost(), do: @shared_cost

  @voip :voip
  def voip(), do: @voip

  @personal_number :personal_number
  def personal_number(), do: @personal_number

  @pager :pager
  def pager(), do: @pager

  @uan :uan
  def uan(), do: @uan

  @voicemail :voicemail
  def voicemail(), do: @voicemail

  @unknown :unknown
  def unknown(), do: @unknown

  defmacro __using__(_) do
    quote do
      @fixed_line :fixed_line
      @mobile :mobile
      @fixed_line_or_mobile :fixed_line_or_mobile
      @toll_free :toll_free
      @premium_rate :premium_rate
      @shared_cost :shared_cost
      @void :voip
      @personal_number :personal_number
      @pager :pager
      @uan :uan
      @voicemail :voicemail
      @unknown :unknown
    end
  end
end
