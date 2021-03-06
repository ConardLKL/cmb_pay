require 'base64'
require 'digest/md5'
require 'openssl' # For RC4/RSA/SHA1

module CmbPay
  module Sign
    CMB_PUBLIC_KEY = File.read(File.expand_path('./public.key', __dir__)).freeze

    module Sha1WithRsa
      def self.verify(param_string)
        pub = OpenSSL::PKey::RSA.new(CMB_PUBLIC_KEY)
        pub.verify('sha1', signature(param_string), plain_text(param_string))
      end

      private_class_method

      def self.plain_text(param_string)
        param_string[0, param_string.index('&Signature=')]
      end

      def self.signature(param_string)
        sign = param_string[param_string.index('&Signature=') + 11, param_string.length - 1]
        sign.split('|').map { |ascii_code| ascii_code.to_i.chr }.join('')
      end
    end

    # CMB replace '+' with '*' according to standard Base64
    def self.encode_base64(bin)
      ::Base64.strict_encode64(bin).tr('+', '*')
    end

    def self.md5_key_digest(str_key)
      Digest::MD5.hexdigest(str_key.encode('gb2312')).upcase
    end

    def self.rc4_encrypt(md5_hash, data)
      cipher = OpenSSL::Cipher.new('RC4')
      cipher.encrypt
      cipher.key = Util.hex_to_binary(md5_hash)
      cipher.update(data.encode('gb2312')) + cipher.final
    end

    def self.sha1_digest(str)
      OpenSSL::Digest::SHA1.hexdigest(str)
    end
  end
end
