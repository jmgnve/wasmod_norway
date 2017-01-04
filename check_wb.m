function wb = check_wb(settings,sim)
%CHECK_WB Compute errors in the water balance
%
%   Function call:
%   wb = check_wb(settings,sim)
%
%   Input variables:
%   settings - constains initial state variables
%   sim - simulation results

% Compute change in water storages

dST = sim.STORE(end) - settings.ST;
dAK = sim.SNOWP(end) - settings.AK;

% Compute total inputs and outputs

wb_in  = sum(sim.PREC);
wb_out = sum(sim.AET) + sum(sim.Q);

% Check error in water balance computations

wb = dST + dAK - wb_in + wb_out;

% Print results

disp(['Error in water balance computations (mm): ' num2str(abs(wb),'%.3f')])

end

