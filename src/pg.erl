%% Copyright (c) 2020 Nicolas Martyanoff <khaelin@gmail.com>.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
%% REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
%% AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
%% INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
%% LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
%% OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
%% PERFORMANCE OF THIS SOFTWARE.

-module(pg).

-export([start_pool/2,
         pool_stats/1,
         acquire/1, release/2,
         with_client/2, with_transaction/2,
         exec/2, exec/3, exec/4,
         query/2, query/3, query/4]).

-export_type([pool_id/0,
              query_options/0, query_result/0, exec_result/0,
              column_name/0, row/0,
              oid/0, float_value/0,
              point/0, line_segment/0, path/0, box/0, polygon/0, line/0,
              circle/0,
              inet_address/0, mac_address/0,
              date/0, time/0, time_with_timezone/0, timestamp/0,
              interval/0,
              uuid/0]).

-type pool_id() :: atom().

-type query_options() :: #{column_names_as_atoms => boolean(),
                           rows_as_hashes => boolean()}.

-type query_result() :: {ok,
                         [column_name()],
                         [row()],
                         NbAffectedRows :: non_neg_integer()}
                      | {error,
                         pg_proto:error_and_notice_fields()}.
-type exec_result() :: {ok,
                        NbAffectedRows :: non_neg_integer()}
                     | {error,
                        pg_proto:error_and_notice_fields()}.

-type column_name() :: binary() | atom().

-type row() :: [term()] | #{column_name() := term()}.

-type oid() :: non_neg_integer().

-type float_value() :: float() | nan | positive_infinity | negative_infinity.

-type point() :: {float(), float()}.
-type line_segment() :: {Start :: point(), End :: point()}.
-type path() :: {open | closed, [point()]}.
-type box() :: {UpperRight :: point(), LowerLeft :: point()}.
-type polygon() :: [point()].
-type line() :: {A :: float(), B :: float(), C :: float()}. % Ax + By + C
-type circle() :: {Center :: point(), Radius :: float()}.

-type inet_address() :: {inet:ip4_address(), NetMask :: 0..32}
                      | {inet:ip6_address(), NetMask :: 0..128}.
-type mac_address() :: <<_:48>> | <<_:64>>.

-type time() :: {0..23, 0..59, 0..59, 0..1_000_000} | {24, 0, 0, 0}.
-type time_with_timezone() :: {0..23, 0..59, 0..59, 0..1_000_000,
                               Offset :: integer()}
                            | {24, 0, 0, 0,
                               Offset :: integer()}.
-type date() :: {integer(), 1..12, 1..31}
              | positive_infinity | negative_infinity.
-type timestamp() :: {date(), time()}.

-type interval() :: {Months :: integer(), Days :: integer(),
                     Microseconds :: integer()}.

-type uuid() :: <<_:128>>.

-spec start_pool(pg:pool_id(), pg_pool:options()) ->
        supervisor:startchild_ret().
start_pool(Id, Options) ->
  pg_sup:start_pool(Id, Options).

-spec pool_stats(pool_id()) -> pg_pool:stats().
pool_stats(PoolId) ->
  pg_pool:stats(pg_pool:process_name(PoolId)).

-spec acquire(pool_id()) -> {ok, pg_client:ref()} | {error, term()}.
acquire(PoolId) ->
  pg_pool:acquire(pg_pool:process_name(PoolId)).

-spec release(pool_id(), pg_client:ref()) -> ok.
release(PoolId, Client) ->
  pg_pool:release(pg_pool:process_name(PoolId), Client).

-spec with_client(pool_id(), pg_pool:client_fun()) -> term() | {error, term()}.
with_client(PoolId, Fun) ->
  pg_pool:with_client(pg_pool:process_name(PoolId), Fun).

-spec with_transaction(pool_id(), pg_pool:client_fun()) ->
        term() | {error, term()}.
with_transaction(PoolId, Fun) ->
  pg_pool:with_transaction(pg_pool:process_name(PoolId), Fun).

-spec exec(pg_client:ref(), Query :: unicode:chardata()) -> exec_result().
exec(Ref, Query)  ->
  pg_client:exec(Ref, Query, [], #{}).

-spec exec(pg_client:ref(), Query :: unicode:chardata(), Params :: [term()]) ->
        exec_result().
exec(Ref, Query, Params) ->
  pg_client:exec(Ref, Query, Params, #{}).

-spec exec(pg_client:ref(), Query :: unicode:chardata(), Params :: [term()],
           query_options()) -> exec_result().
exec(Ref, Query, Params, Options) ->
  pg_client:exec(Ref, Query, Params, Options).

-spec query(pg_client:ref(), Query :: unicode:chardata()) -> query_result().
query(Ref, Query) ->
  pg_client:query(Ref, Query, [], #{}).

-spec query(pg_client:ref(), Query :: unicode:chardata(), Params :: [term()]) ->
        query_result().
query(Ref, Query, Params) ->
  pg_client:query(Ref, Query, Params, #{}).

-spec query(pg_client:ref(), Query :: unicode:chardata(), Params :: [term()],
            query_options()) -> query_result().
query(Ref, Query, Params, Options) ->
  pg_client:query(Ref, Query, Params, Options).
