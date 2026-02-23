% Intro_script;
% Inputs = ['Inputs: '];
% Vars = ['Vars: '];
% Arrays = ['array: '];
% Assignments = [""];
% SessionResetJobs = [""];
% Entries = [""];
% Exits = [""];
%
% Michael_formula;
%
% Inputs = chg_last_coma_semicolumn(Inputs);
% Vars = chg_last_coma_semicolumn(Vars);
% Arrays = chg_last_coma_semicolumn(Arrays);
%
%
%
% out = [Intro; ""; Inputs; Vars; Arrays; ""; Assignments; ""; SessionResetJobs; ""; Entries; ""; Exits];

% exx = strrep(fileread('demoscript.txt'),newline,'');
% out = [char(Intro(1)), newline, char(Intro(2)), newline, exx];
% app.codeArea.Value = out;


%%just a test...
% Inputs = [Inputs;...
%     string(['sessBegin(',num2str(1700),'),sessEnd(',num2str(1600),'),'])];

% clear;
clc;

if 0
    %% basics
    mycontracts = 1;
    strat_side = 1; %1 = long+short 2 = solo long 3 = solo short
    noReverse = 0;
    titanExport = 1;
    titan_start_date = datetime(2008,01,1);
    
    %% michael
    sess_start = 1700;
    sess_end = 1600;
    
    %% trigger
    trigg_no = 7;
    trigg_hhll = 3;
    
    %% tw
    tw_start = 1730;
    tw_end = 1530;
    tw_pauseOn = 1;
    tw_pause_start = 100;
    tw_pause_end = 800;
    
    %% ptn
    ptn_type = 1; %1 = PtnBaseSA2, 2 = PtnFast, 3 = PtnNeut+Dir
    
    %% filters
    filt_sma_on = 1;
    filt_sma_type = 1;
    filt_ADX_on = 1;
    filt_Div_on = 1;
    filt_Div_type = 1; %1 = RSI 2 = MACD
    filt_max_daily_entries_on = 1;
    filt_max_daily_entries = 2;
    
    %% exits tweaks
    max_trade_duration_type = 3;
    max_trade3_sessions = 8;
    flat_time = 1530;
    stp = 1000;
    be = 1500;
    tgt = 5000;
    trail_onoff = 1;
    trail_trigg = 2500;
    trail_dist = 50;

    %% AI
    askToWarren = 1;
    request_to_ai = '<USER_INSTRUCTIONS>\n- aggiungi un filtro per il quale non opero nel mese di agosto per la parte long e non opero a settembre, giugno e maggio per la parte short.\n- Voglio operare long solo nei giorni del mese pari e short solo nei giorni dispari;\n- nel trigger ingresso, fai in modo che si entri a rottura del massimo più alto delle ultime 5 sessioni e viceversa per la parte short.\n</USER_INSTRUCTIONS>';

end

%% code
[s_michael, inputs, vars, assign, assign_at_reset, en_cond0, en_condL, en_condS, en_orderL, en_orderS, assign_post_entries, pos_mgmt, titan_s, s_script, s_intro] = deal('');

%intro
s_intro = ['//MultiCharts/TradeStation code generator by Unger Academy. All rights reserved.\n//Script generation datetime: ' datestr(now)];

%MICHAEL
s_michael = ['//Michael formula calculation begin\nInput:SessionStartTimeA(' num2str(sess_start) '), sessionEndTimeA(' num2str(sess_end)...
    '); //Set here your session time!\narray:ohlcvalues[23](0), adxCalcValues[3](0);\nvar:IsStartOfSession(false);\n\nIsStartOfSession=_ohlcmulti5(SessionStartTimeA,sessionEndTimeA,ohlcvalues);\n//Michael formula calculation end'];

%% INIT SCRIPT
inputs = ['Inputs: MyContracts(', num2str(mycontracts), '), //Choose with how many contracts you want to work\n\tMyStartTime(', num2str(tw_start), '), MyEndTime(', num2str(tw_end),'), ',...
    iif(tw_pauseOn,[inputs 'MyStartPause(' num2str(tw_pause_start) '), MyEndPause(' num2str(tw_pause_end) '),'],'MyStartPause(1200), MyEndPause(1100),') ' //Time window and pause']; ... %pause];
    
vars = 'vars:';
en_cond0 = ['//ENTRIES\nif tw(MyStartTime,MyEndTime) and (Time<MyStartPause or Time>MyEndPause) ']; ... % tw + pause
    assign_at_reset = 'if isStartOfSession then begin';

assign = char("//VARIABLES' CALCULATION");

%% Pattern
switch ptn_type %1 = PtnBaseSA2, 2 = PtnFast, 3 = PtnNeut+Dir
    case 1
        inputs = [inputs '\n\tPtnLY(41), PtnLN(42), PtnSY(41), PtnSN(42), //optimize from 1 to 41 (41=true, 42=false)'];
        en_condL = [en_condL 'and PtnBaseSA2(PtnLY,ohlcvalues) and PtnBaseSA2(PtnLN,ohlcvalues)=false '];
        en_condS = [en_condS 'and PtnBaseSA2(PtnSY,ohlcvalues) and PtnBaseSA2(PtnSN,ohlcvalues)=false '];
    case 2
        inputs = [inputs '\n\tPtnLY(152), PtnLN(153), PtnSY(152), PtnSN(153), //optimize from 1 to 152 (152=true, 153=false)'];
        en_condL = [en_condL 'and PatternFast(PtnLY,ohlcvalues) and PatternFast(PtnLN,ohlcvalues)=false '];
        en_condS = [en_condS 'and PatternFast(PtnSY,ohlcvalues) and PatternFast(PtnSN,ohlcvalues)=false '];
    case 3
        en_cond0 = [en_cond0 'and PatternNeutralFast(PtnNeutYes,ohlcvalues) and PatternNeutralFast(PtnNeutNo,ohlcvalues)=false '];
        en_condL = [en_condL 'and PatternDirectionalFast(PtnDirYes,ohlcvalues) and PatternDirectionalFast(PtnDirNo,ohlcvalues)=false '];
        en_condS = [en_condS 'and PatternDirectionalFast(-PtnDirYes,ohlcvalues) and PatternDirectionalFast(-PtnDirNo,ohlcvalues)=false '];
        inputs = [inputs '\n\tPtnNeutYes(55),PtnNeutNo(56),PtnDirYes(52),PtnDirNo(53), //optimize Neutral from 1 to 55 (55=true, 56=false). Directional from -52 to 52 (52=true, 53=false)'];
    case 4
        inputs = [inputs '\n\tPtnLY(6), PtnLN(6), PtnSY(7), PtnSN(7), //optimize from 1 to 6 (6=true, 7=false)'];
        en_condL = [en_condL 'and PatternLite(PtnLY,ohlcvalues) and PatternLite(PtnLN,ohlcvalues)=false '];
        en_condS = [en_condS 'and PatternLite(PtnSY,ohlcvalues) and PatternLite(PtnSN,ohlcvalues)=false '];        
end

%% no reverse
if noReverse
    en_cond0 = [en_cond0 'and marketposition=0 '];
end

%% Max entries per day
if filt_max_daily_entries_on
    inputs = [inputs '\n\tMaxEntriesPerDay(' num2str(filt_max_daily_entries) '), //Set maximum entries per calendar day'];
    en_cond0 = [en_cond0 'and entriestoday(date)<MaxEntriesPerDay '];
end

%% ADX
if filt_ADX_on
    inputs = [inputs '\n\tADX_TH(100), //Set maximum ADX value'];
    vars = [vars 'ADXval(0), '];
    assign_at_reset = [assign_at_reset '\n\tADXval = iADXOnArray(5, ohlcValues[5], ohlcValues[6], ohlcValues[7], ohlcValues[9], ohlcValues[10], ohlcValues[11], adxCalcValues)*100;'];
    en_cond0 = [en_cond0 'and ADXVal<ADX_TH '];
end

%% DIVERGENZE
if filt_Div_on
    vars = [vars 'div(0),'];
    switch  filt_Div_type
        case 1 %RSI
            inputs = [inputs '\n\tRSI_len(14), RSI_OverBoughtTH(80), Div_MinBars(5), Div_MaxBars(100), //RSI divergence settings'];
            assign = [assign '\ndiv = UA_DivergenceRSI_Spotter(Div_MinBars,Div_MaxBars,RSI_OverBoughtTH,RSI_len,value99); '];
        case 2 %MACD
            inputs = [inputs '\n\tMACD_fast(12), MACD_slow(26), MACD_smooth(9), Div_MinBars(5), Div_MaxBars(100), //MACD divergence settings'];
            assign = [assign '\ndiv = UA_DivergenceMACD_Spotter(Div_MinBars,Div_MaxBars,MACD_fast,MACD_slow,MACD_smooth,value99); '];
    end
    en_condL = [en_condL 'and div=1 '];
    en_condS = [en_condS 'and div=-1 '];
end

%% MA
if filt_sma_on
    switch filt_sma_type
        case 1
            inputs = [inputs '\n\tSMA_len(50), //Simple Moving Average length'];
            vars = [vars 'SMA_val(0),'];
            assign = [assign '\nSMA_val = AverageFC(C,SMA_len);'];
            en_condL = [en_condL 'and C>SMA_val '];
            en_condS = [en_condS 'and C<SMA_val '];
        case 2
            inputs = [inputs '\n\tEMA_len(50), //Exponential Moving Average length'];
            vars = [vars 'EMA_val(0),'];
            assign = [assign '\nEMA_val = XAverage(C,EMA_len);'];
            en_condL = [en_condL 'and C>EMA_val '];
            en_condS = [en_condS 'and C<EMA_val '];
    end
end


%inputs = chg_last_coma_semicolumn(inputs);

%% Triggers
switch trigg_no
    case 1 %breakout N sessions ago
        inputs = [inputs '\n\tNSessions(', num2str(trigg_hhll), '), //set the number of sessions ago for breakout trigger - max 5!'];
        vars = [vars 'longLevel(0), shortLevel(0),'];
        assign = [assign '\nlongLevel = ohlcvalues[1+4*NSessions];\nshortLevel = ohlcvalues[2+4*NSessions];'];
        en_orderL = 'then buy("LE") MyContracts contracts next bar longLevel stop;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar shortLevel stop;';
        
    case 2 %price channel brk
        inputs = [inputs '\n\tnBars(', num2str(trigg_hhll),'), //set here the number of bars for channel breakout strategy'];
        vars = [vars 'upperchannel(0), lowerchannel(0),'];
        assign = [assign '\nupperChannel = highest(h,nBars);\nlowerChannel = lowest(l,nBars);'];
        en_orderL = 'then buy("LE") MyContracts contracts next bar upperChannel stop;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar lowerChannel stop;';
        
    case 3 %highest/lowest highsN/lowsN breakout
        inputs = [inputs '\n\tnSessions(', num2str(trigg_hhll),'), //set the number of sessions ago for breakout trigger - max 5!'];
        vars = [vars 'longLevel(0), shortLevel(0), k(0), '];
        assign_at_reset = [assign_at_reset '\n\t//Entry levels calculations...\n\tlongLevel = 0; shortLevel = 99999999999999999;\n\tfor k = 0 to nSessions begin\n\t\tlongLevel = maxlist(longLevel,ohlcvalues[1+k*4]);\n\t\tshortLevel = minlist(shortLevel,ohlcvalues[2+k*4]);\n\tend;'];
        assign = [assign '\nlongLevel = maxlist(longLevel,h); shortLevel = minlist(shortLevel,l);'];
        en_orderL = 'then buy("LE") MyContracts contracts next bar longLevel stop;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar shortLevel stop;';
        
    case 4 %Bollinger reversal
        inputs = [inputs '\n\tBollingerLen(20), BollingerDevs(2), //Set here Bollinger length and deviations'];
        vars = [vars 'bbup(0), bbdn(0),'];
        assign = [assign '\nbbup = BollingerBand(c,BollingerLen,BollingerDevs);\nbbdn = BollingerBand(c,BollingerLen,-BollingerDevs);'];
        en_condL = [en_condL 'and C crosses over bbDn '];
        en_condS = [en_condS 'and C crosses under bbUp '];
        en_orderL = 'then buy("LE") MyContracts contracts next bar market;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar market;';
        
    case 5 %Fade breakout reversal
        vars = [vars 'highd1(0), lowd1(0),'];
        assign = [assign '\nhighd1 = ohlcvalues[5];\nlowd1 = ohlcvalues[6];'];
        en_condL = [en_condL 'and C crosses over lowd1 '];
        en_condS = [en_condS 'and C crosses under highd1 '];
        en_orderL = 'then buy("LE") MyContracts contracts next bar market;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar market;';
        
    case 6 %reversal N sessions ago
        inputs = [inputs '\n\tNSessions(', num2str(trigg_hhll),'), //set the number of sessions ago for reversal trigger - max 5!'];
        vars = [vars 'longLevel(0), shortLevel(0),'];
        assign = [assign '\nlongLevel = ohlcvalues[2+4*NSessions];\nshortLevel = ohlcvalues[1+4*NSessions];'];
        en_orderL = 'then buy("LE") MyContracts contracts next bar longLevel limit;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar shortLevel limit;';
        
    case 7 %highest/lowest sessions high/low limit reverse
        inputs = [inputs '\n\tnSessions(', num2str(trigg_hhll),'), //set the number of sessions ago for reversal trigger - max 5!'];
        vars = [vars 'longLevel(0), shortLevel(0), k(0), '];
        assign_at_reset = [assign_at_reset '\n\t//Entry levels calculations...\n\tshortLevel = 0; longLevel = 99999999999999999;\n\tfor k = 1 to nSessions begin\n\t\tshortLevel = maxlist(shortLevel,ohlcvalues[1+k*4]);\n\t\tlongLevel = minlist(longLevel,ohlcvalues[2+k*4]);\n\tend;'];
        en_orderL = 'then buy("LE") MyContracts contracts next bar longLevel limit;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar shortLevel limit;';
        
    case 8 %Bias - market
        inputs = [inputs '\n\tMyLETime(0), MyLXTime(0), MySETime(0), MySXTime(0), testPhase(0), //set here the hours of the day to enter/exit from the market'];
        en_condL = [en_condL 'and Time=MyLETime '];
        en_condS = [en_condS 'and Time=MySETime '];
        en_orderL = 'then buy("LE") MyContracts contracts next bar market;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar market;';
        en_cond0 = [en_cond0 'and testPhase=0 '];
        pos_mgmt = [pos_mgmt iif(strat_side~=3,'\nif Time=MyLXTime then sell("LX_Time") next bar market;','') iif(strat_side~=2,'\nif Time=MySXTime then buytocover("SX_Time") next bar market;','')];
        
    case 9 %Bias - stop
        inputs = [inputs '\n\tMyLETime(0), nBarsLong(4), MyLXTime(0), MySETime(0), nBarsShort(4), MySXTime(0), testPhase(0), //set here the hours of the day to enter/exit from the market'];
        en_condL = [en_condL 'and Time=MyLETime '];
        en_condS = [en_condS 'and Time=MySETime '];
        en_orderL = 'then buy("LE") MyContracts contracts next bar highest(h,nBarsLong) stop;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar lowest(l,nBarsShort) stop;';
        en_cond0 = [en_cond0 'and testPhase=0 '];
        pos_mgmt = [pos_mgmt iif(strat_side~=3,'\nif Time=MyLXTime then sell("LX_Time") next bar market;','') iif(strat_side~=2,'\nif Time=MySXTime then buytocover("SX_Time") next bar market;','')];
    
    case 10 %Bias - limit
        inputs = [inputs '\n\tMyLETime(0), nBarsLong(4), MyLXTime(0), MySETime(0), nBarsShort(4), MySXTime(0), testPhase(0), //set here the hours of the day to enter/exit from the market'];
        en_condL = [en_condL 'and Time=MyLETime '];
        en_condS = [en_condS 'and Time=MySETime '];
        en_orderL = 'then buy("LE") MyContracts contracts next bar lowest(l,nBarsLong)[1] limit;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar highest(h,nBarsShort)[1] limit;';
        en_cond0 = [en_cond0 'and testPhase=0 '];
        pos_mgmt = [pos_mgmt iif(strat_side~=3,'\nif Time=MyLXTime then sell("LX_Time") next bar market;','') iif(strat_side~=2,'\nif Time=MySXTime then buytocover("SX_Time") next bar market;','')];
    
    case 11 %sma cross
        inputs = [inputs '\n\tentry_SMA1_len(50), entry_SMA2_len(100), //choose there the length for Simple Moving Average trigger'];
        vars = [vars 'trigger_sma1(0), trigger_sma2(0),'];
        assign = [assign '\ntrigger_sma1 = AverageFC(C,entry_SMA1_len);\ntrigger_sma2 = AverageFC(C,entry_SMA2_len);'];
        en_condL = [en_condL 'and trigger_sma1 crosses over trigger_sma2 '];
        en_condS = [en_condS 'and trigger_sma1 crosses under trigger_sma2 '];
        en_orderL = 'then buy("LE") MyContracts contracts next bar market;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar market;';
        
    case 12 %Jumper
        en_orderL = 'then buy("LE") MyContracts contracts next bar H stop;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar L stop;';
        
    case 13 %Ranger
        inputs = [inputs '\n\tmult(0), //choose the multiplier for long/short entries'];
        en_orderL = 'then buy("LE") MyContracts contracts next bar L - mult*range limit;';
        en_orderS = 'then sellshort("SE") MyContracts contracts next bar H + mult*range limit;';
end

%% position management
if trigg_no<8 || trigg_no>10 %con il bias non serve...
    %trade duration
    switch max_trade_duration_type
        case 1 %no limit
            %do nothing!
        case 2 %intraday
            inputs = [inputs '\n\tFlatTime(' num2str(flat_time) '),//Set here at what time to close the position'];
            pos_mgmt = [pos_mgmt '\nsetexitonclose;\nif Time=flatTime then begin',...
                iif(strat_side~=3,'\n\tsell("LX_EoD") next bar market;',''),...
                iif(strat_side~=2,'\n\tbuytocover("SX_EoD") next bar market;',''),...
                '\nend;'];
        case 3 %max number of sessions!
            inputs = [inputs '\n\tMaxDaysInTrade(' num2str(max_trade3_sessions) '), FlatTime(' num2str(flat_time) '), //Set here the maximum number of days to stay in the market and the flat time!'];
            vars = [vars 'DaysInTrade(0), mp(0), '];
            assign_at_reset = [assign_at_reset '\n\t//Keep track of how many days the strategy has been in position\n\tif marketposition<>0 then daysintrade=daysintrade+1;'];
            assign = [assign '\nmp = marketposition;'];
            assign_post_entries = [assign_post_entries '\nif mp<>mp[1] and mp<>0 then daysintrade=1;'];
            pos_mgmt = [pos_mgmt '\nif daysintrade>=maxDaysInTrade and maxDaysInTrade>0 then begin\n\tsetexitonclose;\n\tif Time=FlatTime then begin',...
                iif(strat_side~=3,'\n\t\tif marketposition=1 then sell("LX_MaxDays") next bar market;',''),...
                iif(strat_side~=2,'\n\t\tif marketposition=-1 then buytocover("SX_MaxDays") next bar market;',''),...
                '\n\tend;\nend;'];
    end
end

% sl, be, tgt
if stp+be+tgt>0
    pos_mgmt = [pos_mgmt iif(strlength(pos_mgmt)>0,'\n','') '\nsetstopcontract;'];
end

if stp>0
    inputs = [inputs '\n\tMyStop(' num2str(stp) '), //Set here your stoploss! (0=disabled)'];
else
    inputs = [inputs '\n\tMyStop(0), //Set here your stoploss! (0=disabled)'];
end
pos_mgmt = [pos_mgmt '\nif mystop>0 then setstoploss(MyStop);'];

if be>0
    inputs = [inputs '\n\tMyBreakEven(' num2str(be) '), //Set here your breakeven stop!(0=disabled)'];
else
    inputs = [inputs '\n\tMyBreakEven(0), //Set here your breakeven stop!(0=disabled)'];
end
pos_mgmt = [pos_mgmt '\nif MyBreakEven>0 then setbreakeven(MyBreakEven);'];

if tgt>0
    inputs = [inputs '\n\tMyProfit(' num2str(tgt) '), //Set here your profit target! (0=disabled)'];
else
    inputs = [inputs '\n\tMyProfit(0), //Set here your profit target! (0=disabled)'];
end
pos_mgmt = [pos_mgmt '\nif MyProfit>0 then setprofittarget(MyProfit);'];

if trail_onoff>0
    inputs = [inputs '\n\tTrailTrigger(' num2str(trail_trigg) '), TrailPercentDistance(' num2str(trail_dist) '), TrailingEnabled(' num2str(trail_onoff) '), //Set here trailing stop trigger and percentage distance from runup'];
    vars = [vars 'DistOpenRunup(0), '];
    pos_mgmt = [pos_mgmt '\n\n//Trailing stop\nDistOpenRunup = OpenEntryMaxProfitPerContract/bigpointvalue;\nif TrailingEnabled=1 and OpenEntryMaxProfitPerContract>=TrailTrigger and TrailTrigger>0 and TrailPercentDistance>0 and barssinceentry>1 then begin',...
        iif(strat_side~=3,'\n\tif marketposition=1 then sell("LX_trail") next bar entryprice + DistOpenRunup*(1-TrailPercentDistance/100) stop;',''),...
        iif(strat_side~=2,'\n\tif marketposition=-1 then buytocover("SX_trail") next bar entryprice - DistOpenRunup*(1-TrailPercentDistance/100) stop;',''),...
        '\nend;'];
end

%% unisci
idx = strfind(inputs,',');
if ~isempty(idx)
    inputs(idx(end)) = ';';
end
idx = strfind(vars,',');
if ~isempty(idx)
    vars(idx(end)) = ';';
end

assign_at_reset = [assign_at_reset '\nend;\n'];
en_cond0 = [en_cond0 'then begin'];

en_condL(1:2) = 'if'; en_condS(1:2) = 'if';
en_condL(3) = []; en_condS(3) = [];
if strlength(pos_mgmt)>0
    pos_mgmt = ['\n\n//POSITION MANAGEMENT' pos_mgmt ];
end

s_script = [s_intro '\n\n',...
    s_michael '\n\n',...
    inputs '\n\n',...
    iif(~strcmpi(vars,'vars:'),[vars '\n'],''),...
    iif(strlength(assign_at_reset)>38,['\n' assign_at_reset '\n'],''),...
    iif(~strcmpi(assign,char("//VARIABLES' CALCULATION")),assign,''),...
    iif(trigg_no>=8 & trigg_no<=10,'\n\nif testPhase=1 then begin\n\tif Time=MyLeTime then buy next bar market;\n\tif marketposition=1 then sell next bar market;\nend;',''), '\n\n',...
    en_cond0,...
    iif(strat_side~=3,['\n\t' en_condL en_orderL],''),...
    iif(strat_side~=2,['\n\t' en_condS en_orderS],''),...
    '\nend;\n',...
    iif(strlength(assign_post_entries)>0,assign_post_entries,''),...
    iif(strlength(pos_mgmt)>0,pos_mgmt,'') ];

%% Titan export
if titanExport
    s_script = [s_script '\n\n//TITAN FAST EXPORT\nInput: TitanExportEnabled(0);\nif TitanExportEnabled=1 then WriteDailiesCTitanReports(' num2str(str2double(datestr(titan_start_date,'yyyymmdd'))-19*10^6) ',TitanExportEnabled);'];
end

if askToWarren
    wb = f_waitbar_text_left(waitbar(0,'Contacing AI server...'));
    waitbar(.1,wb,'Contacing AI server...');
    user_prompt = ['<USER_CODE>', s_script, '</USER_CODE>\n\n<USER_INSTRUCTIONS>', request_to_ai, '</USER_INSTRUCTIONS>'];
    token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNjI2MDQiLCJmaXJzdF9uYW1lIjoidGhvcmFuIiwibGFzdF9uYW1lIjoicmVxdWlyZWQiLCJlbWFpbCI6InRyYWRpbmdAdGhvcmFuLmNvbSIsImlhdCI6MTcxMjIxOTc2OSwiZXhwIjoxODEyMzA2MTY5LCJ0YWdzIjpbIjEyMiIsIjIxOCIsIjI0MiIsIjI0NCIsIjI0NiIsIjI0OCIsIjI1MCIsIjI1MiIsIjI1NCIsIjI1NiIsIjM0OCIsIjQ0MiIsIjUzNCIsIjUzNiIsIjUzOCIsIjU0MCIsIjU0MiIsIjU0NiIsIjU0OCIsIjU3MCIsIjU4MiIsIjU5NCIsIjU5NiIsIjU5OCIsIjYxNCIsIjYxNiIsIjYxOCIsIjYyMCIsIjYzMCIsIjYzOCIsIjY3OCIsIjY4NCIsIjY5MCIsIjcxOCIsIjcyMCIsIjcyMiIsIjcyNiIsIjcyOCIsIjc4MiIsIjgzNCIsIjg3NCIsIjk0NCIsIjk2OCIsIjk3MiIsIjk3NCIsIjk3NiIsIjk4MiIsIjEyNTQiLCIxMjc2IiwiMTI5MCIsIjEyOTIiLCIxMzAyIiwiMTMwNCIsIjEzMDYiLCIxMzI2IiwiMTM1OCIsIjEzNjYiLCIxNDE0IiwiMTQ0NCIsIjE0NTYiLCIxNDU4IiwiMTQ2MCIsIjE0NjIiLCIxNDY0IiwiMTUxNCIsIjE1MTYiLCIxNzA4IiwiMTcxOCIsIjE3MzYiLCIxODMwIiwiMjAwNCIsIjIwNTAiLCIyMDk0IiwiMjA5OCIsIjIxMDIiLCIyMTA2IiwiMjExMCIsIjIxMjYiLCIyMjE0IiwiMjIxOCIsIjIyNTYiLCIyMjY2IiwiMjMwNiIsIjIzMDgiLCIyMzEwIiwiMjMxMiIsIjIzMjIiLCIyMzI0IiwiMjMzMCIsIjIzMzIiLCIyMzM4IiwiMjM0MCIsIjI1MjQiLCIyNTU4IiwiMjU2MiIsIjI1NjYiLCIyNTc2IiwiMjU4NCIsIjI2MDIiLCIyNjIwIiwiMjY2OCIsIjI2ODgiLCIyNjk0IiwiMjY5NiIsIjI3MDgiLCIyNzUyIiwiMjc1NCIsIjI3NzAiLCIyNzg0IiwiMjgwNCIsIjI5OTQiLCIyOTk2IiwiMzAzMiIsIjMwMzgiLCIzMDQwIiwiMzA5NiIsIjMxMDAiLCIzMTA0IiwiMzE3MiIsIjMzMjAiLCIzMzI2IiwiMzQyNCIsIjM0MzYiLCIzNTUwIiwiMzU3MCIsIjM2MDEiLCIzNjM5IiwiMzcwMyIsIjQwOTkiLCI0MTAxIiwiNDI4NyIsIjUyODYiLCI1MzU1IiwiNTM1NyIsIjU1ODIiLCI1NTg2IiwiNTczMiIsIjU4NTAiLCI1ODUyIiwiNTkwMCIsIjU5OTQiLCI2MzMwIiwiNzEwMiIsIjcxMjQiXSwiaXNzIjoidW5nZXJhY2FkZW15LmNvbSJ9.ZcDdkC6mJENR9FqgNmNoPn2YI_0nmDg0Rz0Hc9mDT40';
    chatID = ['COMPOSERAI-' num2str(posixtime(datetime('now'))*1000, '%.0f') '-' num2str(randi([1, 10000]))];
    data = struct( ...
        'chatId', chatID, ...
        'prompt', user_prompt, ...
        'promptTemplate', 'composerai' ...
        );

    % URL dell'API
    url = 'https://api.ungeracademy.com/chats';

    % fai la domanda a Warren
    options = weboptions( ...
        'HeaderFields', { ...
            'Authorization', token; ...
            'Content-Type', 'application/json' ...
        }, ...
        'Timeout',30 ...
        );
    response = webwrite(url, data, options);
    options = weboptions( ...
        'HeaderFields', { ...
            'Authorization', token ...
        },...
        'Timeout',30 ...
        );


    waitbar(.5,wb,'Request sent to AI service: waiting for a response...');

    % Fai fetch della risposta e merge dei chunks
    for k=1:20
        waitbar(.5+.5*k/20,wb,'Waiting for a response from AI service...');
        reply = webread(strcat(url,'?page=1&pagesize=1&filter={"chatId": "',chatID,'"}'),options);
        if isfield(reply,'status') && strcmpi(reply.status,'complete')
            break;
        end
        pause(3);
    end

    close(wb);

    chunks = reply.chunks;
    % s_script = '';
    % for i = 1:length(chunks)
    %     s_script = [s_script, chunks{i}];
    % end

    s_script = strjoin(chunks,'');
end

a = sprintf(s_script);
c = strsplit(a,'\n','CollapseDelimiters',false)';
%disp(a);