require 'rails_helper'

RSpec.describe 'date_time', type: :view do
  class DateTimeModel
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def initialize(column_sql_type)
      @column_sql_type = column_sql_type
    end

    def persisted?
      true
    end

    def column_for_attribute(*)
      if @column_sql_type.is_a?(Symbol)
        Struct.new(:type).new(@column_sql_type)
      else
        Struct.new(:sql_type).new(@column_sql_type)
      end
    end

    def has_attribute?(*)
      true
    end

    def test
      @test ||= DateTime.now
    end
  end

  subject! do
    simple_form_for object, url: 'test' do |f|
      f.input :test
    end
    render html: output_buffer
  end

  context 'when the database column is a datetime' do
    ['datetime', :datetime].each do |type|
      let(:object) { DateTimeModel.new(type) }
      it 'displays the text field' do
        expect(rendered).to have_tag('div.form-group.bootstrap_date_time') do
          with_tag('input.bootstrap_date_time', with: { value: object.test })
        end
      end

      it 'has a hidden datepicker control' do
        selector = 'div.form-group.bootstrap_date_time div.input-group'
        required_style = { style: 'display: none' }

        expect(rendered).to have_tag(selector, with: required_style) do
          with_tag('input.bootstrap_date_time', with: { type: 'hidden' })
        end
      end
    end
  end

  context 'when the database column is a date' do
    ['date', :date].each do |type|
      let(:object) { DateTimeModel.new(type) }
      it 'displays the text field' do
        expect(rendered).to have_tag('div.form-group.bootstrap_date') do
          with_tag('input.bootstrap_date', with: { value: object.test })
        end
      end
    end
  end

  context 'when the database column is not a datetime' do
    let(:object) { DateTimeModel.new('string') }
    it 'does not have a datepicker control' do
      expect(rendered).not_to have_tag('div.form-group.bootstrap_date_time')
    end
  end
end
