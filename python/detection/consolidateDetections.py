import os
import multiprocessing
from multiprocessing import Manager
import time

import numpy as np

import obspy
from obspy import read
import obspyh5

import h5py

import eqcorrscan
from eqcorrscan.core.match_filter import read_detections
from eqcorrscan.core.match_filter import Tribe
from eqcorrscan.core.match_filter import Template
from eqcorrscan.core.match_filter import match_filter

# set distance between detections in each band to count as event
tolerance = 60

# read in detections
detHigh = read_detections('templateDetections_1-10Hz.csv')
detLow = read_detections('templateDetections_0.01-1Hz.csv')

detHighTimes = [f.detect_time for f in detHigh]
detLowTimes = [f.detect_time for f in detLow]

# keep low frequency detections if there is a high frequency detection within the tolerance
events = []
lastIdx = 0
for i in range(len(detLow)-1):

    # get number of days since arbitrary start date (Jan 1, 2012)
    detLowDay = np.floor((detLowTimes[i]-obspy.UTCDateTime(2012,1,1,00))/60/60/24)
    detLowDayNext = np.floor((detLowTimes[i+1]-obspy.UTCDateTime(2012,1,1,00))/60/60/24)

    # start timer
    timer = time.time()

    # get high frequency detections on current day
    detHighTimesToday = []
    for j in range(lastIdx,len(detHigh)):

        # get number of days since arbitrary start date (Jan 1, 2012)
        detHighDay = np.floor((detHighTimes[j]-obspy.UTCDateTime(2012,1,1,00))/60/60/24)

        # record time if day numbers are equal
        if detHighDay == detLowDay:
            detHighTimesToday.append(detHighTimes[j])

        # if next low frequency detection is on next day, update iteration start index
        if detLowDay < detLowDayNext:
            lastIdx = j

        # exit loop when current high and low frequency detections are no longer on the same day
        if detHighDay > detLowDay:
            break

    # calculate difference between current detection and all high frequency detections
    diffs = abs(np.subtract(detLowTimes[i],detHighTimesToday))

    # save low frequency detections if minimum difference is less than threshold time
    if min(diffs) < tolerance:
        events.append(detLow[i])
    #print(events)

    # stop timer and give output
    runtime = time.time() - timer
    print(str(round(i/len(detLow) * 100)) + "% done with consolidation")
    #print(str(round(runtime*(len(detLow)-i)/60)) + " minutes left")

print("Found "  + str(len(events)) + " events")

# find amount by which detection value exceeded threshold
threshDiff = np.zeros((len(events)))
for i in range(len(events)):
    threshDiff[i] = abs(events[i].detect_val)-abs(events[i].threshold)

# sort based on amount by which detection value exceeded threshold
sortIdx = np.argsort(threshDiff)
sortIdx = np.flip(sortIdx)
print(sortIdx)
eventsQualitySort = []
for f in sortIdx:
    eventsQualitySort.append(events[f])

#print(events)
for eventsQualitySort in eventsQualitySort:
    eventsQualitySort.write('templateEventsQualitySort.csv',append=True)
for events in events:
    events.write('templateEventsTimeSort.csv',append=True)
