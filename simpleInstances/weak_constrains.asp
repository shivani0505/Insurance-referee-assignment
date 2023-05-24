%% Weak Constrain 1 %%
%% Internal referees are preferred in order to minimize the costs of external ones. %%

	:~ S = #sum{CASEPAYMENT, CID : assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE = e, assign(CID,RID)}. [S*16]

%% Weak Constrain 2 %%
%% The assignment of cases to external referees should be fair in the sense that their overall payment should be balanced %%

	ext_payment(S) :- S = #sum{CASEPAYMENT, CID : assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
									, referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE = e, assign(CID,RID)}.
									
	prev_payment(Y) :- Y = #sum{REF_PREV_PAYM, RID : referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE = e, assign(CID,RID)}.

	ext_ref_count(EXT_COUNT) :- EXT_COUNT = #count{RID : referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE = e}.

	:~ assign(CID,RID), AVG = (S+Y)/EXT_COUNT, ext_payment(S), prev_payment(Y), ext_ref_count(EXT_COUNT)
		, case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), COST = |AVG-REF_PREV_PAYM|. [COST*7]
	
%% Weak Constrain 3 %%
%% The assignment of cases to (internal and external) referees should be fair in the sense that their overall workload should be balanced%%

	total_case_wl(S) :- S = #sum{EFFORT, CID : assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
									, referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), assign(CID,RID)}.
									
	prev_wl(Y) :- Y = #sum{PREV_WL, RID : referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), assign(CID,RID)}.

	ref_count(R_COUNT) :- R_COUNT= #count{RID : referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM)}.
	
	avg_wl(S) :- S = (W+Y)/R_COUNT, total_case_wl(W), prev_wl(Y), ref_count(R_COUNT).
	
	cost_wl(Z) :- Z = |S-PREV_WL-EFFORT|, avg_wl(S), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
		, referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM).

	:~ assign(CID,RID), AVG = (S+Y)/R_COUNT, total_case_wl(S), prev_wl(Y), ref_count(R_COUNT)
		, case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), COST = |AVG-PREV_WL-EFFORT|. [COST*9]

	
%% Weak Constrain 4 %%
%% Referees should handle types of cases with higher preference.%%

	:~ assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM),prefType(RID, PREF_CASETYPE, PREF),COST_TYPE = 3-PREF. [COST_TYPE*34]
		
%% Weak Constrain 5 %%
%% Referees should handle cases in regions with higher preference.%%

	:~ assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), prefRegion(RID, PREF_PCODE, PREF), COST_REGION = 3-PREF. [COST_REGION*34]