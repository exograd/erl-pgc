%% Copyright (c) 2020-2022 Exograd SAS.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
%% SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
%% IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(pgc_codec_jsonb).

-behaviour(pgc_codec).

-export([encode/4, decode/4]).

-spec encode(binary(), pgc_types:type(), pgc_types:type_set(), list()) -> iodata().
encode(Bin, _, _, []) ->
  [<<1:8>>, Bin].

-spec decode(binary(), pgc_types:type(), pgc_types:type_set(), list()) -> binary().
decode(<<1:8, Bin/binary>>, _, _, []) ->
  Bin;
decode(<<Version:8, _Bin/binary>>, _, _, []) ->
  throw({error, {invalid_jsonb_version, Version}});
decode(Data, _, _, []) ->
  throw({error, {invalid_data, Data}}).
