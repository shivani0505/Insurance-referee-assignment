{assign(CID,RID):referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM)}=1:-case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  soft constraints                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	#minimize{COST_TYPE@34, CID : assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), prefType(RID, PREF_CASETYPE, PREF)
	                               , PREF >= 1, COST_TYPE = 3-PREF}.

%Referee Region Preference

	#minimize{COST_REGION@34, CID : assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), prefRegion(RID, PREF_PCODE, PREF)
					, PREF >= 1, COST_REGION = 3-PREF}.

%The sum of all payments of cases assigned to external referees should be minimized

	internal_over_ext(CASEPAYMENT,CID):-case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT),assign(CID,RID),referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM),RTYPE = e.
	internal_over_ext(0,CID):-case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT),assign(CID,RID),referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), not RTYPE = e.
	
	#minimize{COST_REF@16,CID : internal_over_ext(COST_REF,CID)}.
	
%%The assignment of cases to (internal and external) referees should be fair in the sense that their overall workload should be balanced.

	wl_divergence(WL_DIVERGENCE,CID) :- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM)
  	                        , avg_ref_total_workload(AVG_TOTAL_WL), ref_total_worload(RID, R_TOTAL_WL), WL_DIVERGENCE = (AVG_TOTAL_WL-R_TOTAL_WL).
  	
  	#maximize{WL_DIVERGENCE@9,CID : wl_divergence(WL_DIVERGENCE,CID)}.
  	
  	%#show wl_divergence/2.
  	%#show avg_ref_total_workload/1.
  	%#show ref_total_worload/2.
  	
%assignment of cases to external referees should be fair in the sense that their overall payment should be balanced

	payment_divergence(P_DIVERGENCE,CID) :- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE=e, ext_ref_count(EXT_COUNT)
 	                         , avg_ext_ref_total_payment(AVG_TOTAL_EXT_PAYM), ext_ref_total_payment(RID, REF_TOTAL_PAYM), P_DIVERGENCE = (AVG_TOTAL_EXT_PAYM-REF_TOTAL_PAYM).
 	                         
 	payment_divergence(0,CID) :- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), not RTYPE=e.
 	                         
 	#maximize{P_DIVERGENCE@7, CID : payment_divergence(P_DIVERGENCE,CID)}.

%%The assignment of cases to (internal and external) referees should be fair in the sense that their overall workload should be balanced.
%count number of referee
	ref_count(R_COUNT) :- R_COUNT= #count{RID : referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM)}.

%overall workload of the referee who got new cases assigned
	ref_total_worload(RID, (PREV_WL+EFFORT)) :- assign(CID,RID)
                                           , case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
                                           , referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM).

%overall workload of referee who did not get any case today
	ref_total_worload(RID, PREV_WL) :- not assign(CID,RID)
                                 , case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
                                 , referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM).

%total workload of referee till date.
	sum_ref_total_workload(TOTAL_WL) :- TOTAL_WL = #sum{WL, RID : ref_total_worload(RID, WL)}.
	avg_ref_total_workload(TOTAL_WL/R_COUNT) :- sum_ref_total_workload(TOTAL_WL), ref_count(R_COUNT).


%	#show ref_total_worload/2.
%	#show avg_ref_total_workload/1.
	
%assignment of cases to external referees should be fair in the sense that their overall payment should be balanced
%count number of external referee
	ext_ref_count(EXT_COUNT) :- EXT_COUNT= #count{RID : referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE = e}.

%overall payment recieved by ext referee who got cases assigned
	ext_ref_total_payment(RID, (REF_PREV_PAYM+CASEPAYMENT)) :- assign(CID,RID)
                                                        , case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
                                                        , referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE=e.
%overall payment recieved by ext referee who did not get any case today
	ext_ref_total_payment(RID, REF_PREV_PAYM) :- not assign(CID,RID)
                                                , case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)
                                                , referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), RTYPE=e.

%total payment recieved by ext referee overall till date.
	sum_ext_ref_total_payment(TOTAL_EXT_PAYM) :- TOTAL_EXT_PAYM = #sum{E_PAYM, RID : ext_ref_total_payment(RID, E_PAYM)}.
	avg_ext_ref_total_payment(TOTAL_EXT_PAYM/EXT_COUNT) :- sum_ext_ref_total_payment(TOTAL_EXT_PAYM), ext_ref_count(EXT_COUNT).

%	#show ext_ref_total_payment/2.
%	#show avg_ext_ref_total_payment/1.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			hard constraints			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Referee case Type Preference
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), prefType(RID, PREF_CASETYPE, PREF), not CASETYPE=PREF_CASETYPE.
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), prefType(RID, PREF_CASETYPE, PREF), CASETYPE = PREF_CASETYPE, PREF<1. 

%Referee case Region Preference
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), prefRegion(RID, PREF_PCODE, PREF), not PCODE=PREF_PCODE.
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), prefRegion(RID, PREF_PCODE, PREF), PCODE=PREF_PCODE, PREF<1.

%Cases with an amount of damage that exceeds a certain threshold can only be assigned to internal referees
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), externalMaxDamage(MAXDAMAGE), RTYPE=e, DAMAGE > MAXDAMAGE.

%The maximum number of working minutes of a referee must not be exceeded by the actual workload
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), EFFORT > MAX_WL.
	
#show assign/2.
