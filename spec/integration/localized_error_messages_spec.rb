# frozen_string_literal: true

require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema, 'with localized messages' do
  before do
    I18n.config.available_locales = [:en, :pl]
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
    I18n.reload!
  end

  describe 'defining schema' do
    context 'without a namespace' do
      subject(:schema) do
        Dry::Schema.define do
          configure do
            config.messages = :i18n
          end

          required(:email).value(:filled?)
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(schema.(email: '').messages(locale: :pl)).to eql(
            email: ['Proszę podać adres email']
          )
        end
      end
    end

    context 'with a namespace' do
      subject(:schema) do
        Dry::Schema.define do
          configure do
            configure do |config|
              config.messages = :i18n
              config.namespace = :user
            end
          end

          required(:email).value(:filled?)
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(schema.(email: '').messages(locale: :pl)).to eql(
            email: ['Hej user! Dawaj ten email no!']
          )
        end
      end
    end
  end
end
