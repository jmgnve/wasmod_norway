function sse = wasmod_wrapper(A,ip,settings,Qobs)
%WASMOD_WRAPPER Code needed for running parameter optimization routine
%
%   Function call:
%   sse = wasmod_wrapper(A,ip,settings,Qobs)
%
%   Input variables:
%   A - vector with parameter values
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
pa.A7 = A(7);

pa.fa = ip.fa;

% Run model

sim = wasmod(st,ip,pa,settings.mc,1,false);

% Compute performance measure

sim.Q = sim.Q(settings.warmup:end); 
Qobs = Qobs(settings.warmup:end);
sim.Q = sim.Q(:); Qobs = Qobs(:);
inan = isnan(sim.Q) | isnan(Qobs);

sse = sum((sim.Q(~inan)-Qobs(~inan)).^2);

end

