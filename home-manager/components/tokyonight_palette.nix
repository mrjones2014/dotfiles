{ lib, ... }:
rec {
  bg_dark = "#1a1b26";
  bg = "#24283b";
  bg_highlight = "#292e42";
  terminal_black = "#414868";
  fg = "#c0caf5";
  fg_dark = "#a9b1d6";
  fg_gutter = "#3b4261";
  dark3 = "#545c7e";
  comment = "#565f89";
  dark5 = "#737aa2";
  blue0 = "#3d59a1";
  blue = "#7aa2f7";
  cyan = "#7dcfff";
  blue1 = "#2ac3de";
  blue2 = "#0db9d7";
  blue5 = "#89ddff";
  blue6 = "#b4f9f8";
  blue7 = "#394b70";
  magenta = "#bb9af7";
  magenta2 = "#ff007c";
  purple = "#9d7cd8";
  orange = "#ff9e64";
  yellow = "#e0af68";
  green = "#9ece6a";
  green1 = "#73daca";
  green2 = "#41a6b5";
  teal = "#1abc9c";
  red = "#f7768e";
  red1 = "#db4b4b";

  # Convert hex digit to decimal
  hexDigitToInt =
    c:
    if c == "0" then
      0
    else if c == "1" then
      1
    else if c == "2" then
      2
    else if c == "3" then
      3
    else if c == "4" then
      4
    else if c == "5" then
      5
    else if c == "6" then
      6
    else if c == "7" then
      7
    else if c == "8" then
      8
    else if c == "9" then
      9
    else if c == "a" || c == "A" then
      10
    else if c == "b" || c == "B" then
      11
    else if c == "c" || c == "C" then
      12
    else if c == "d" || c == "D" then
      13
    else if c == "e" || c == "E" then
      14
    else if c == "f" || c == "F" then
      15
    else
      throw "Invalid hex digit: ${c}";

  # Convert 2-digit hex string to decimal
  hexToInt =
    hex:
    let
      chars = lib.stringToCharacters (lib.toLower hex);
      high = hexDigitToInt (builtins.elemAt chars 0);
      low = hexDigitToInt (builtins.elemAt chars 1);
    in
    high * 16 + low;

  # Function to convert hex color to RGB ANSI background escape sequence
  hexToAnsiRgb =
    hexColor:
    let
      # Remove the # prefix and extract RGB components
      cleanHex = builtins.substring 1 6 hexColor;
      r = hexToInt (builtins.substring 0 2 cleanHex);
      g = hexToInt (builtins.substring 2 2 cleanHex);
      b = hexToInt (builtins.substring 4 2 cleanHex);
    in
    "${toString r};${toString g};${toString b}";
}
