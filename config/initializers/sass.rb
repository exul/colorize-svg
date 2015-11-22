require 'sass'
require 'cgi'

module Sass::Script::Functions
  def colorize_svg(svg_name, color)
    svg = read_file(svg_name)
    change_stroke_color!(svg, color)
    encode_svg(svg)
  end

  def colorize_svg_with_placeholders(svg_name, placeholder_colors)
    svg = read_file(svg_name)
    placeholder_colors.to_a.each do |placeholder_color|
      placeholder, color = placeholder_color.to_a
      change_color!(svg, placeholder, color)
    end
    encode_svg(svg)
  end

  private

  def read_file(svg_name)
    asset = Rails.application.assets.find_asset(svg_name.value)
    raise "File not found: #{svg_name}" unless asset

    File.read(asset.pathname)
  end

  def change_stroke_color!(svg, color)
    raise "Not a valid color: #{color}" unless color.is_a?(Sass::Script::Color)

    svg.gsub!(/stroke=\"([^\"])*\"/, "stroke=\"#{color}\"")
  end

  def change_color!(svg, placeholder, color)
    raise "Not a valid color: #{color}" unless color.is_a?(Sass::Script::Color)

    svg.gsub!("#{placeholder}", "#{color}")
  end

  def encode_svg(svg)
    encoded_svg = CGI::escape(svg).gsub('+', '%20')
    svg_data = "url('data:image/svg+xml;charset=utf-8," + encoded_svg + "')"
    Sass::Script::String.new(svg_data)
  end
end
