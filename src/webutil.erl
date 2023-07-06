-module(webutil).

-export([load_html/1]).

-spec load_html(FilePath :: string()) -> Html :: binary().
load_html(FilePath) ->
  {ok, Binary} = file:read_file(FilePath),
  Binary.

