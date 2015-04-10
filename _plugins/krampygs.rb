require 'kramdown'
require 'pygments'
require 'typogruby'

module Kramdown
  module Converter
    class Pygs < Html
      def convert_codeblock(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr) || @options[:coderay_default_lang]
        code = pygmentize(el.value, lang)
        code_attr = {}
        code_attr['class'] = "language-#{lang}" if lang
        "#{' '*indent}<pre#{html_attributes(attr)}><code#{html_attributes(code_attr)}>#{code}</code></pre>\n"
      end

      def convert_codespan(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr) || @options[:coderay_default_lang]
        code = pygmentize(el.value, lang)
        if lang
          if attr.has_key?('class')
            attr['class'] += " language-#{lang}"
          else
            attr['class'] = "language-#{lang}"
          end
        end
        "<code#{html_attributes(attr)}>#{code}</code>"
      end
      
      def pygmentize(code, lang)
        if lang
          Pygments.highlight(code,
            :lexer => lang,
            :options => { :encoding => 'utf-8', :nowrap => true })
        else
          escape_html(code)
        end
      end
    end
  end
end

module Jekyll
  class KramdownPygments < Jekyll::Converter
    def matches(ext)
      ext =~ /^\.md$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      content = encrypt_private(content)

      html = Kramdown::Document.new(content, {
          :auto_ids             => @config['kramdown']['auto_ids'],
          :footnote_nr          => @config['kramdown']['footnote_nr'],
          :entity_output        => @config['kramdown']['entity_output'],
          :toc_levels           => @config['kramdown']['toc_levels'],
          :smart_quotes         => @config['kramdown']['smart_quotes'],
          :coderay_default_lang => @config['kramdown']['default_lang'],
          :input                => @config['kramdown']['input']
      }).to_pygs
      return Typogruby.improve(html)
    end

    def encrypt_private(content)
      start_falg = '<private>'
      end_flag = '</private>'
      start_index = content.index(start_falg)
      end_index = -1
      sub_str = ''
      while start_index >= 0 do
        end_index = content.index(end_flag)
        if end_index <= 0 or end_index < start_index
          start_index = content.index(start_falg)
          next
        end
        sub_str = content[start_index..end_index]
        content[sub_str] = '***'
        start_index = content.index(start_falg)
      end
      content = content.gsub(start_falg, '')
      content = content.gsub(end_flag, '')
      return 'content'
    end
  end
end
