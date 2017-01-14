function res = wasmod_wrapper(A, A7, ip, settings, Qobs)
%WASMOD_WRAPPER Code needed for running parameter optimization routine
%
%   Function call:
%   res = wasmod_wrapper(A, A7, ip, settings, Qobs)
%
%   Input variables:
%   A - vector with parameter values
%   A7 - precipitation correction factor
%   ip - struct containing input variables
%   settings - struct containing settings
%   Qobs - observed discharge

% Struct for initial states

st.AK = settings.AK;  % Snow storage
st.ST = settings.ST;  % Land moisture

% Struct for parameter values

pa.A1 = A(1);
pa.A2 = A(2);
pa.A3 = A(3);
pa.A4 = A(4);
pa.A5 = A(5);
pa.A6 = A(6);

pa.A7 = A7;
pa.fa = ip.fa;

% Run model

sim = wasmod(st, ip, pa, settings.mc, 1, false);

% Compute performance measure

[ns, ~, ~, ~, ~] =  performance(sim.Q, Qobs, settings.warmup);

res = 1 - ns;

end

