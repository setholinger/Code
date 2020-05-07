% script to automatically retrieve arrival times using cross correlation
% and 1 starting pick

% set up station/channel parameters
%load('stationInfo.mat')
%stat = stat(1:9,:);
%fs = fs(1:9);
dataPath = "/media/Data/Data/";
%fsResamp =  min(fs);
fileLen = 86400*fsResamp;

% set event to be located
%dayStr = "2012-04-02";
%detection = datetime(2012,4,2,15,18,00,00);
%pick = datetime(2012,4,2,15,18,00,00)+seconds(2725/fsResamp);
%detLen = 5*60*fsResamp;

% set filter parameters
%freq = [1,10];
%filtType = "bandpass";

% load data
eventData = zeros(size(stat,1),detLen);
for n = 1:size(stat,1)

    % make filename
    fname = dataPath + stat(n,1) + "/MSEED/noIR/" + stat(n,2) + "/" + stat(n,3) +"/" + dayStr + "." + stat(n,2) + "." + stat(n,3) + ".noIR.MSEED";
    
    % read file and extract data
    dataStructure = rdmseed(fname);
    trace = extractfield(dataStructure,'d');
    %dataStructure = rdmseedfast(fname);
    %trace = extractfield(dataStructure,'data');
    
    % filter and resample the trace
    [b,a] = butter(4,freq/(fs(n)),filtType);
    trace = filtfilt(b,a,trace);
    if fs(n) ~= fsResamp
        trace = resample(trace,fsResamp,fs(n));
    end

    % extract event data
    startInd = (hour(detection)*60*60+minute(detection)*60+second(detection))*fsResamp;
    endInd = startInd+detLen-1;
    eventTrace = detrend(trace(startInd:endInd));
    eventData(n,:) = eventTrace;
end

% get offset times with cross correlation
arrivalsDatetime = NaT(size(stat,1),1);
for n = 1:size(stat,1)
    [xcorrTrace,lag] = xcorr(eventData(1,:),eventData(n,:),'coeff');
    [coef,lagIdx] = max(abs(xcorrTrace));
    offset = lag(lagIdx)*-1;
    arrivalsDatetime(n) = pick+seconds(offset/fsResamp);
end

