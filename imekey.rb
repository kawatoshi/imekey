# -*- coding: utf-8 -*-
module Imekey
	class Word
		require 'MeCab'
		require 'romaji'
		require 'moji'
		attr_reader :source
		attr_accessor :yomigana

		def initialize(str)
			@cab = MeCab::Tagger.new('-O chasen')
			self.set_source(str)
		end
		def set_source(str)
			@source = zen_to_han(escape(str))
			parse
		end
		def word_size
			@words.size
		end
		def kana
			@words.map {|w| [w[1], Moji.type(w[1])]}
		end
		def hira
			@words.map do |w|
				if Moji.type?(w[1], Moji::KANA)
					wd = Moji.kata_to_hira(Moji.han_to_zen(w[1]))
				else
					wd = w[1]
				end
				[wd, Moji.type(wd)]
			end
		end
		def hiragana
			ary = hira.map {|w| w[0]}
			ary.join
		end
		def roma
			@words.map do |w|
				wd = Romaji.kana2romaji(w[1])
				[wd, Moji.type(w[1])]
			end
		end
		def source_ime
			@words.map do |w|
				wd = imeroma(w[1]).join
				[wd, Moji.type(w[1])]
			end
		end
		def yomigana_ime
			[[imeroma(@yomigana).join, Moji.type(@yomigana)]]
		end
		def ime
			if @yomigana
				yomigana_ime
			else
				source_ime
			end
		end

		private
		def escape(str)
			str.gsub(/㈱/, "(株)")
		end
		def parse
			ws = @cab.parse(@source).force_encoding('utf-8').split(/\n/)
			ws.pop
			@words = ws.map {|w| w.split(/\t/)}
		end
		def zen_to_han(str)
			ans = Moji.zen_to_han(str, Moji::ZEN_ASYMBOL)
			ans = Moji.zen_to_han(ans, Moji::ZEN_ALNUM )
			ans = Moji.zen_to_han(ans, Moji::ZEN_GREEK )
			ans = Moji.zen_to_han(ans, Moji::ZEN_CYRILLIC )
			Moji.zen_to_han(ans, Moji::ZEN_LINE )
		end
		def imeroma(str)
			str.chars.to_a.map do |w|
				if Moji.type?(w, Moji::KANA)
					case w
					when 'ョ'
						"xyo"
					when 'ュ'
						"xyu"
					when 'ァ'
						"xa"
					when 'ィ'
						"xi"
					when 'ェ'
						"xe"
					when 'ォ'
						"xo"
					when 'ャ'
						"xya"
					when 'ヶ'
						"xke"
					else
					 	Romaji.kana2romaji(w).gsub(/\An\Z/,"nn")
					end
				elsif Moji.type?(w, Moji::ZEN_JSYMBOL)
					case w
					when "ー"
						" OEM(-) "
					when "・"
						" OEM(/) "
					when "、"
						","
					else
						w
					end
				else
					w
				end
			end
		end
	end
end
