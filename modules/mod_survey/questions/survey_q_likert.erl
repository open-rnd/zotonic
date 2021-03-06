%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2011 Marc Worrell

%% Copyright 2011 Marc Worrell
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(survey_q_likert).

-export([
    answer/3,
    prep_chart/3,
    prep_answer_header/2,
    prep_answer/3,
    prep_block/2,
    to_block/1
]).

-include("zotonic.hrl").
-include("../survey.hrl").

to_block(Q) ->
    [
        {type, survey_matching},
        {is_required, Q#survey_question.is_required},
        {name, z_convert:to_binary(Q#survey_question.name)},
        {prompt, z_convert:to_binary(Q#survey_question.question)}
    ].

answer(Block, Answers, _Context) ->
    Name = proplists:get_value(name, Block),
    case proplists:get_value(Name, Answers) of
        <<C>> when C >= $1, C =< $5 -> {ok, [{Name, C - $0}]};
        undefined -> {error, missing}
    end.


prep_chart(_Block, [], _Context) ->
    undefined;
prep_chart(Block, [{_, Vals}], Context) ->
    Labels = [<<"1">>,<<"2">>,<<"3">>,<<"4">>,<<"5">>],
    LabelsDisplay = [<<"Strongly agree">>,<<"Agree">>,<<"Neutral">>,<<"Disagree">>,<<"Strongly disagree">>],

    Values = [ proplists:get_value(C, Vals, 0) || C <- Labels ],
    Sum = case lists:sum(Values) of 0 -> 1; N -> N end,
    Perc = [ round(V*100/Sum) || V <- Values ],
    [
        {question, z_html:escape(proplists:get_value(prompt, Block), Context)},
        {values, lists:zip(LabelsDisplay, Values)},
        {type, "pie"},
        {data, [{L,P} || {L,P} <- lists:zip(LabelsDisplay, Perc), P /= 0]}
    ].

prep_answer_header(Block, _Context) ->
    proplists:get_value(name, Block).

prep_answer(_Q, [], _Context) ->
    <<>>;
prep_answer(_Q, [{_Name, {Value, _Text}}], _Context) ->
    Value.

prep_block(B, _Context) ->
    B.


