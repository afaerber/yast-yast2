# Simple example to demonstrate object API for CWM

require_relative "example_helper"

require "cwm/widget"

Yast.import "CWM"
Yast.import "Wizard"

class LuckyNumberWidget < CWM::IntField
  attr_reader :result, :minimum, :maximum

  def initialize
    @minimum = 0
    @maximum = 1000
  end

  def label
    _("Lucky number")
  end

  def store
    @result = value
  end
end

class GenerateButton < CWM::PushButton
  def initialize(lucky_number_widget)
    @lucky_number_widget = lucky_number_widget
  end

  def label
    _("Generate Lucky Number")
  end

  def handle
    Yast::Builtins.y2milestone("handle called")
    @lucky_number_widget.value = rand(1000)

    nil
  end
end

class LuckyNumberGenerator < CWM::CustomWidget
  def contents
    HBox(
      button_widget,
      lucky_number_widget
    )
  end

  def result
    lucky_number_widget.result
  end

private

  def button_widget
    @button_widget ||= GenerateButton.new(lucky_number_widget)
  end

  def lucky_number_widget
    @lucky_number_widget ||= LuckyNumberWidget.new
  end
end

module Yast
  class ExampleDialog
    include Yast::I18n
    include Yast::UIShortcuts
    include Yast::Logger
    def run
      textdomain "example"

      generate_widget = LuckyNumberGenerator.new

      contents = HBox(generate_widget)

      Yast::Wizard.CreateDialog
      CWM.show(contents, caption: _("Lucky number"))
      Yast::Wizard.CloseDialog

      log.info "The result is #{generate_widget.result}"
    end
  end
end

Yast::ExampleDialog.new.run
