*!TITLE: RBW - residual balancing weights for marginal structural models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.9 - 10/11/2019 - GT Wodtke
*!

program define rbw, eclass

	version 13	

	syntax varlist(min=1 numeric), gen(string) [basewts(varname numeric)]
	
	mata: m_find("found")
	
	if found == 0 {
		display as error "{p 0 0 5 0}The -rbw- command requires the -moremata- package to be installed.{p_end}"
		display as error "This package can be installed using -ssc install moremata-"
		error 199			
		}
		
	else {

		marksample touse
			
		local residual_terms `varlist'
				
		local balance_weights `gen'
		
		confirm new variable `balance_weights'
		
		if "`basewts'" == "" {
			local base_wt false	
			local base_wt_names "_bweights_001 _bweights_010 _bweights_100"
			foreach name of local base_wt_names {
				capture confirm new variable `name'
				if !_rc {
					local base_weights `name'
					continue, break
					}
				}
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create a new variable"
				display as error "with one of the following names: `base_wt_names', "
				display as error "but these variables have already been defined.{p_end}"
				error 110
				}
			gen `base_weights' = 1
			}
			
		else {
			local base true
			local base_weights `basewts'
			}

		mata: m_resbal("`residual_terms'", "`balance_weights'", "`base_weights'", "`touse'")
	
		if ("`base_wt'"=="false") {
			drop `base_weights'
			}
		}
		
	capture scalar drop found

end

	
************************************************************************
///define mata function m_find to verify whether -moremata- is installed

capture mata mata drop m_find()

version 13

mata:
	
	void m_find(string scalar found) {
		
	I = (findexternal("mm_ebal()") != NULL)

	st_numscalar(found, I)

	}
	
end

capture mata mata drop m_resbal()

version 13

///end m_find
************************************************************************


**********************************************************************
///define mata function m_resbal to compute residual balancing weights

mata:
	
	void m_resbal(string scalar residual_terms, string scalar balance_weights, string scalar base_weights, string scalar touse) { 
		
		resterms = st_data(., residual_terms, touse)
		
		intercept = J(rows(resterms), 1, 1)
		
		C = intercept, resterms
		
		B = st_data(., base_weights, touse)

		M = J(1, 1, rows(resterms)), J(1, cols(resterms), 0)

		S = mm_ebal_init(M, sum(B), C, B)

		(void) mm_ebal(S)

		W = mm_ebal_W(S)

		NVAR = st_addvar("float", balance_weights)

		st_store(., NVAR, W)

		}
		
end

/// end m_resbal
**********************************************************************
