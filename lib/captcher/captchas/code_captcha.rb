module Captcher
  module Captchas
    class CodeCaptcha < BaseCaptcha
      SPECIAL_CHAR_CODES = (91..96).freeze

      self.name = :code_captcha

      # rubocop:disable Naming/MemoizedInstanceVariableName
      def after_initialize
        @payload ||= random_text
      end
      # rubocop:enable Naming/MemoizedInstanceVariableName

      # rubocop:disable Lint/UnusedMethodArgument
      def represent(format = :html, options = {})
        Captcher::TextImage.new(@payload, own_config).generate
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def validate(confirmation)
        confirmation.to_s.strip.casecmp(@payload).zero?
      end

      private

      def random_text
        @random_text = own_config[:include_digits] ? random_text_with_digits : random_letters_text
      end

      def random_letters_text
        Array.new(own_config[:count]) { random_char }.join("")
      end

      def random_text_with_digits
        count = own_config[:count].to_i
        count_nums = count / 2
        count_letters = count - count_nums
        nums_list = Array.new(count_nums) { rand(10) }
        letters_list = Array.new(count_letters) { random_char }
        shuffle_string(nums_list + letters_list)
      end

      def shuffle_string(list)
        shuffled_str = list.shuffle.join
        sequence_incorrect?(shuffled_str) ? shuffle_string(list) : shuffled_str
      end

      def sequence_incorrect?(str)
        count = own_config[:count].to_i
        count_nums = count / 2
        numeric_string?(str[0...count_nums]) || numeric_string?(str[-count_nums...count])
      end

      def numeric_string?(str)
        !Float(str).nil?
      rescue StandardError
        false
      end

      def random_char
        random_char_code.chr
      end

      def random_char_code
        char_code = ("A".ord + (rand * ("z".ord - "A".ord)).floor)
        char_code.in?(SPECIAL_CHAR_CODES) ? random_char_code : char_code
      end
    end
  end
end
