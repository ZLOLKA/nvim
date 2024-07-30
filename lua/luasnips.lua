local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

local function my_fmt(str, arr)
  return fmt(str, arr, {
    delimiters = "<>"
  })
end

ls.add_snippets("cpp", {
  s("namespace", my_fmt([[
  namespace <> {

  <>

  }  // namespace <>
  ]], {i(1), i(0), rep(1)}
  )),

  s("class", my_fmt([[
  class <> {
    <>
  };  // class <>
  ]], {i(1), i(0), rep(1)}
  )),

  s("struct", my_fmt([[
  struct <> {
    <>
  };  // struct <>
  ]], {i(1), i(0), rep(1)}
  )),
})

ls.filetype_extend("cpp", {"c", "h", "hpp"})
