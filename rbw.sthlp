{smcl}
{* *! version 0.9, 11 October 2019}{...}
{cmd:help for rbw}{right:Geoffrey T. Wodtke}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:rbw} {hline 2}}residual balancing weights for marginal structural models{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:rbw} {varlist}{cmd:,} gen({newvarname}) [basewts({varname})]

{phang}{opt varlist} - this specifies a list of variables that define elements of the constraint matrix, that is, 
a list of variables that contain (i) the residualized confounders, (ii) cross-products between the residualized 
confounders and future treatments, and (iii) cross-products between the residualized confounders and their regressors.

{phang}{opt gen(varname)} - this specifies the name of a new variable that will contain the residual balancing weights.


{title:Options}

{phang}{opt basewts(varname)} - this option specifies a set of base weights; if left unspecified, the command applies a base 
weight of 1 to all observations by default.


{title:Description}

{pstd} When estimating the joint effects of a time-varying treatment on an end-of-study outcome using a marginal structural model (MSM), 
analysts may need to adjust for time-varying confounders that are possibly affected by prior treatments. The method of residual 
balancing adjusts for these types of confounders. It involves (1) residualizing each time-varying confounder with respect to prior 
treatments and prior confounders; (2) finding a set of weights that exactly balances these residual terms across future treatments, 
prior treatments, and prior confounders while minimizing their relative entropy with respect to a set of base weights; and (3) fitting 
an MSM for the end-of-study oucome using these weights. {cmd:rbw} computes the set of minimum entropy weights that appropriately balance 
the residualized confounders and are then used to fit the MSM of interest. The command requires the user to supply the elements of a 
contraint matrix that have target moments of zero. The constraint matrix should contain the residualized time-varying confounders, a set 
of cross-products between the residualized confounders and future treatments, and another set of cross-products between the residualized 
confounders and their regressors from the models used to compute them. The command optionally allows the user to supply a set of base
weights. These should be a set of survey sampling weights or a vector of ones (the default). See references for further details. {p_end}


{title:Examples}

{pstd}A simulated data example with a continuous end-of-study outcome (y), a treatment measured at time 1 (a1) and time 2 (a2),
and a time-varying confounder measured at time 1 (c1) and time 2 (c2): {p_end}

{phang2}Step 1 - Residualize the time-varying confounders {p_end}

{phang2}{cmd:. use rbw_example.dta} {p_end}
 
{phang2}{cmd:. reg c1} {p_end}

{phang2}{cmd:. predict c1r, resid} {p_end}

{phang2}{cmd:. reg c2 c1 a1} {p_end}

{phang2}{cmd:. predict c2r, resid} {p_end}


{phang2}Step 2 - Compute the appropriate cross-product terms {p_end}

{phang2}{cmd:. gen c1rXa1=c1r*a1} {p_end}

{phang2}{cmd:. gen c1rXa2=c1r*a2} {p_end}

{phang2}{cmd:. gen c2rXc1=c2r*c1} {p_end}

{phang2}{cmd:. gen c2rXa1=c2r*a1} {p_end}

{phang2}{cmd:. gen c2rXa2=c2r*a2} {p_end}


{phang2}Step 3 - Assemble elements of the constraint matrix {p_end}

{phang2}{cmd:. global cmat c1r c2r c1rXa1 c1rXa2 c2rXc1 c2rXa1 c2rXa2} {p_end}


{phang2}Step 4 - Use {cmd:rbw} to compute the balancing weights {p_end}

{phang2}{cmd:. rbw $cmat, gen(rbalwts)} {p_end}


{phang2}Step 5 - Fit an MSM for the outcome {p_end}

{phang2}{cmd:. reg y c.a1##c.a2 [pw=rbalwts]} {p_end}


{title:Author}

{pstd}Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{p_end}

{phang}Email: wodtke@uchicago.edu


{title:References}

{pstd}Zhou X and Wodtke GT. (2019). Residual Balancing: A Method of Constructing Weights for Marginal Structural Models. ArXiv preprint. https://arxiv.org/abs/1807.10869 {p_end}


{title:Acknowledgments}

{pstd}This command is based on the {cmd:mm_ebal()} mata function by Ben Jann. {p_end}


{title:Also see}

{psee}
Help: {manhelp regress R}, {manhelp predict R}, {manhelp moremata R}
{p_end}
