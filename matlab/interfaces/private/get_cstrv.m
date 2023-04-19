function cstrv = get_cstrv(x, Aineq, bineq, Aeq, beq, lb, ub, nlcineq, nlceq)
%GET_CSTRV calculates the (absolute) constraint violation of x. Note that `nlcineq` and `nlceq` are
% values of the nonlinear inequality and equality constraints, the inequality constraint being
% nlcineq <= 0. `nlcineq` and `nlceq` are optional, while all the other inputs are obligatory.
callstack = dbstack;
funname = callstack(1).name; % Name of the current function
if nargin < 7
    % Private/unexpected error
    error(sprintf('%s:InvalidNargin', funname), ...
    '%s: UNEXPECTED ERROR: at least 8 inputs expected.', funname);
end
if nargin < 8
    nlcineq = [];
end
if nargin < 9
    nlceq = [];
end

rlb = [];
if ~isempty(lb)
    lb(isnan(lb)) = -Inf; % Replace the NaN in lb with -Inf
    rlb = lb - x;
    rlb(lb <= x) = 0;  % Prevent NaN in case lb = x = +/-Inf; OR: rlb = rlb(~(lb <= x));
end

rub = [];
if ~isempty(ub)
    ub(isnan(ub)) = Inf; % Replace the NaN in ub with Inf
    rub = x - ub;
    rub(x <= ub) = 0;  % Prevent NaN in case ub = x = +/-Inf; OR: rub = rub(~(x <= ub));
end

rineq = [];
if ~isempty(Aineq)
    nan_ineq = isnan(bineq); % NaN inequality constraints
    Aineq = Aineq(~nan_ineq, :); % Remove NaN inequality constraints
    bineq = bineq(~nan_ineq);
    Aix = Aineq*x;
    rineq = Aix - bineq;
    rineq(Aix <= bineq) = 0;  % Prevent NaN in case bineq = Aix = +/-Inf; OR: rineq = rineq(~(Aix <= bineq));
end

req = [];
if ~isempty(Aeq)
    nan_eq = isnan(sum(abs(Aeq), 2)) & isnan(beq); % NaN equality constraints
    Aeq = Aeq(~nan_eq, :); % Remove NaN equality constraints
    beq = beq(~nan_eq);
    Aex = Aeq*x;
    req = Aex - beq;
    req(Aex == beq) = 0;  % Prevent NaN in case beq = Aex = +/-Inf; OR: req = req(~(Aex == beq));
end

% max(X, [], 'includenan') returns NaN if X contains NaN, and maximum of X otherwise
cstrv = max([0; rineq; abs(req); rlb; rub; nlcineq; abs(nlceq)], [], 'includenan');
return
