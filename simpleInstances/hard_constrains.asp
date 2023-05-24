	{assign(CID,RID):referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM)}=1:-case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			hard constraints			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The maximum number of working minutes of a referee must not be exceeded by the actual workload
	totalEffort(S) :- S = #sum{EFFORT,CID : case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT)}.
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), EFFORT > MAX_WL.
	
%Referee case Type Preference
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), not prefType(RID, CASETYPE, _).
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), prefType(RID, PREF_CASETYPE, PREF), CASETYPE = PREF_CASETYPE, PREF<1. 

%Referee case Region Preference
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), not prefRegion(RID, PCODE, _).
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), prefRegion(RID, PREF_PCODE, PREF), PCODE=PREF_PCODE, PREF<1.

%Cases with an amount of damage that exceeds a certain threshold can only be assigned to internal referees
	:- assign(CID,RID), case(CID, CASETYPE, EFFORT, DAMAGE, PCODE, CASEPAYMENT), referee(RID, RTYPE, MAX_WL, PREV_WL, REF_PREV_PAYM), externalMaxDamage(MAXDAMAGE), RTYPE=e, DAMAGE > MAXDAMAGE.

%%%%%%%%%% weak constrains mentioned in weak_constrains.asp %%%%%%%%%%%
	
	#show assign/2.
	