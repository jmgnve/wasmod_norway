function sim = wasmod(st,ip,pa,mc,nruns,output_all)
%WASMOD Model code for WASMOD
%
%   Function call:
%   sim = wasmod(st,ip,pa,mc,nruns,output_all)
%
%   Input variables:
%   st - struct containing states variables (dimension: nelem * nruns)
%   ip - struct containing input variables (dimension: nelem * nsteps)
%   pa - struct containing parameter values (1 * nruns)
%   mc - matrix containing model combinations
%   nruns - number of runs (used for Monte Carlo simulations)
%   output_all - write all results to output

% Model configuration

pe_mod = mc(1);  % Choice for potential evaporation routine (1 to 4)
ae_mod = mc(2);  % Choice for actual evapotranspiration routine (1 to 2)
B1     = mc(3);  % Choice of slow runoff exponent (1 to 2)
B2     = mc(4);  % Choice of fast runoff exponent (1 to 2)

% Initial states

nelem = size(ip.PT,1);

AK = repmat(st.AK,nelem,nruns);  % Snow storage
ST = repmat(st.ST,nelem,nruns);  % Land moisture

% Scale parameter values (lines 700 to 705 in fortran version)

fa = pa.fa;

A1 = pa.A1;
A2 = pa.A2;
A3 = pa.A3;
A4 = pa.A4;
A5 = pa.A5;
A6 = pa.A6;
A7 = pa.A7;

% SCAL(1)=0.1

A1 = A1/.100;   

% SCAL(2)=0.1

A2 = A2/.100;

% IF(IR12.EQ.2)SCAL(4)=100.

if (ae_mod==2)
    A4 = A4/100.000;
end

% IF(ABS(B1-2.).LT.0.001)SCAL(5)=1000.

if (B1==2)
    A5 = A5/1000.000;
end

% IF(ABS(B2-1.).LT.0.001)SCAL(6)=100.

if (B2==1)
    A6 = A6/100.000;
end

% IF(ABS(B2-2.).LT.0.001)SCAL(6)=10000.

if (B2==2)
    A6 = A6/10000.000;
end

% Precipitation correction

A7 = A7/.100;

% Resize arrays

if nelem>1
    A1 = repmat(A1,nelem,1);
    A2 = repmat(A2,nelem,1);
    A3 = repmat(A3,nelem,1);
    A4 = repmat(A4,nelem,1);
    A5 = repmat(A5,nelem,1);
    A6 = repmat(A6,nelem,1);
%     A7 = repmat(A7,nelem,1);
end

if nruns>1
    fa = repmat(fa,1,nruns);
end

% Model loop (see subroutine CALCM02 in fortran version)

nsteps = size(ip.PT,2);  % Number of time steps

for i = 1:nsteps
    
    % Inputs
    
    CT     = ip.CT(:,i);      % Air temperature
    CT_ave = ip.CT_ave(:,i);  % Long-term monthly average temperature
    PT     = ip.PT(:,i);      % Precipitation
    ET     = ip.ET(:,i);      % Potential evaporation
    HT     = ip.HT(:,i);      % Relative humidity
    
    % Resize arrays
    
    if (nruns>1)
        CT      = repmat(CT,1,nruns);
        CT_ave  = repmat(CT_ave,1,nruns);
        PT      = repmat(PT,1,nruns);
        ET      = repmat(ET,1,nruns);
        HT      = repmat(HT,1,nruns);
    end
    
    % Precipitation correction
    
    PT = A7.*PT;
    
    % Snow accumulation
    
    % TT=DMAX1(CT(J),0.)
    % Z=(CT(J)-A(1))/(A(1)-A(2))
    % IF(Z.GE.0.)Z=0.
    % Z=-Z**2
    % ZZ=1.-DEXP(Z)
    % IF(ZZ.LT.0.)ZZ=0.
    % GG(J)=PT(J)*ZZ
    % VV(J)=PT(J)-GG(J)
    
    TT = max(CT,0);
    
    Z = (CT-A1)./(A1-A2);
    Z(Z>=0) = 0;
    Z = -Z.^2;
    ZZ = 1 - exp(Z);
    ZZ(ZZ<0) = 0;
    GG = PT.*ZZ;
    VV = PT-GG;
    
    % Snowmelt
    
    % Z1=(A(2)-CT(J))/(A(1)-A(2))
    % IF(Z1.GE.0.)Z1=0.
    % IF(Z1.LT.0.)Z1=-Z1**2
    % ZZ1=1.-DEXP(Z1)
    % IF(ZZ1.GT.1.)ZZ1=1.
    % IF(ZZ1.LT.0.)ZZ1=0.
    % AH(J)=(AK(J1)+GG(J))*ZZ1
    % RR(J)=VV(J)+AH(J)
    
    Z1=(A2-CT)./(A1-A2);
    Z1(Z1>=0) = 0;
    Z1(Z1<0) = -Z1(Z1<0).^2;
    ZZ1 = 1-exp(Z1);
    ZZ1(ZZ1>1)=1;
    ZZ1(ZZ1<0)=0;
    AH = (AK+GG).*ZZ1;
    RR = VV+AH;
    
    % Potential evaporation
    
    switch pe_mod
        
        case 1
            
            % ER(J)=ET(J)
            
            ER = ET;
            
        case 2
            
            % ER(J)=A(3)*TT**2*(100.-HT(J))
            
            ER = A3.*TT.^2.*(100-HT);
            
        case 3
            
            % ER(J)=A(3)*TT**2
            
            ER = A3.*TT.^2;
            
        case 4
            
            % ER(J)=ET(J)*(1+A(3)*(CT(J)-HT(J)))
            
            ER = ET.*(1+A3.*(CT-CT_ave));
            
    end
    
    % if(ER(J).LT.0.)ER(J)=0.
    
    ER(ER<0) = 0;
    
    % Compute direct loss
    
    % IF(ER(J).GT.1.) THEN
    % VT=ER(J)*(1.-DEXP(-(VV(J)/ER(J))))
    % ELSE
    % VT=ER(J)
    % END IF
    
    icond = ER > 1;
    VT = ER;
    VT(icond) = ER(icond).*(1-exp(-(VV(icond)./ER(icond))));
    
    % Compute active precipitation
    
    % PRTPL=VV(J)-VT
    % IF(PRTPL.LT.0.) PRTPL=0.
    
    PRTPL = VV-VT;
    PRTPL(PRTPL<0)=0;
    
    % Compute available water
    
    % WT=ST(J1)+PRTPL+AH(J)
    
    WT = ST + PRTPL + AH;   
    
    % Actual evapotranspiration
    
    switch ae_mod
        
        case 1
            
            % IF((ER(J)-VT).GT.1..AND.A(4).GT.0.05)THEN
            % RRT=DMIN1((ER(J)-VT)*(1.-A(4)**(WT/(ER(J)-VT))),WT)
            % ELSE
            % RRT=ER(J)-VT
            % ENDIF
            
            icond = (ER-VT)>1 & A4 > 0.05;
            RRT = ER-VT;
            RRT(icond) = min((ER(icond)-VT(icond)).*(1-A4(icond).^(WT(icond)./(ER(icond)-VT(icond)))),WT(icond));
            
        case 2
            
            % RRT=DMIN1(WT*(1.-DEXP(-(ER(J)-VT)*A(4))),(ER(J)-VT))
            
            RRT = min(WT.*(1-exp(-(ER-VT).*A4)),(ER-VT));
            
    end
    
    % RT(J)=RRT+VT
    % IF(RT(J).LT.0.)RT(J)=0.
    
    RT = RRT+VT;
    RT(RT<0) = 0;
    
    % Slow flow component
        
    % IF(A(5).GT.0.)THEN
    % BA(J)=A(5)*ST(J1)**B1
    % ELSE
    % BA(J)=0.
    % ENDIF
        
    icond = A5>0;
    BA=zeros(size(CT));
    BA(icond) = A5(icond).*ST(icond).^B1;
    
    % Fast flow component
    
    % IF(A(6).GT.0.)THEN
    % DA(J)=A(6)*(AH(J)+PRTPL)*ST(J1)**B2
    % ELSE
    % DA(J)=0.
    % ENDIF
    
    icond = A6>0;
    DA=zeros(size(CT));
    DA(icond) = A6(icond).*(AH(icond)+PRTPL(icond)).*ST(icond).^B2;
    
    % Water balance
    
    % DT(J)=BA(J)+DA(J)
    % ST(J)=ST(J1)+AH(J)+PRTPL-RRT-BA(J)-DA(J)
    % IF(ST(J).LT.0.)ST(J)=0.
    % AK(J)=AK(J1)+GG(J)-AH(J)
    
    DT = BA+DA;
    ST = ST+AH+PRTPL-RRT-BA-DA;
    ST(ST<0)=0;
    AK = AK+GG-AH;
    
    % Write outputs
    
    sim.Q(:,i) = sum(DT .* fa,1);  % Total discharge (slow + fast)
    
    if output_all
        
        sim.TEMP(:,i)  = sum(CT .* fa,1);     % Air temperature
        sim.EPT(:,i)   = sum(ER .* fa,1);     % Potential evaporation
        sim.AET(:,i)   = sum(RT .* fa,1);     % Actual evapotranspiration (including direct loss)
        sim.PREC(:,i)  = sum(PT .* fa,1);     % Precipitation
        sim.SNOW(:,i)  = sum(GG .* fa,1);     % Snowfall
        sim.RAIN(:,i)  = sum(VV .* fa,1);     % Rainfall
        sim.MELT(:,i)  = sum(AH .* fa,1);     % Snowmelt
        sim.SNOWP(:,i) = sum(AK .* fa,1);     % Snowpack storage
        sim.STORE(:,i) = sum(ST .* fa,1);     % Land moisture/subsurface storage
        sim.VT(:,i)    = sum(VT .* fa,1);     % Direct loss of precipitation
        sim.FAST(:,i)  = sum(DA .* fa,1);     % Fast runoff
        sim.SLOW(:,i)  = sum(BA .* fa,1);     % Slow runoff
        
    end
    
end
