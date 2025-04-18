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

local function my_fmt_for_tmpl(str, arr)
  return fmt(str, arr, {
    delimiters = "^$"
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
  class <><> {
      <>
  };  // class <>
  ]], {i(1), i(2), i(0), rep(1)}
  )),

  s("struct", my_fmt([[
  struct <><> {
      <>
  };  // struct <>
  ]], {i(1), i(2), i(0), rep(1)}
  )),

  s("co_await", my_fmt([[
  co_await <>;
  ]], {i(0)}
  )),

  s("co_yield", my_fmt([[
  co_yield <>;
  ]], {i(0)}
  )),

  s("co_return", my_fmt([[
  co_return <>;
  ]], {i(0)}
  )),

  s("concept", my_fmt_for_tmpl([[
  template <class T^$>
  concept ^$ = ^$;
  ]], {i(2), i(1), i(0)}
  )),

  s("concept_req", my_fmt_for_tmpl([[
  template <class T^$>
  concept ^$ = requires(T t^$) {
      ^$
  };  // concept ^$
  ]], {i(2), i(1), i(3), i(0), rep(1)}
  )),

  s("templ", my_fmt_for_tmpl([[
  template <class ^$>
  ^$
  ]], {i(1), i(0)}
  )),

  s("templ_req", my_fmt_for_tmpl([[
  template <class ^$>
      requires ^$
  ^$
  ]], {i(1), i(2), i(0)}
  )),
})

ls.filetype_extend("cpp", {"c", "h", "hpp"})
