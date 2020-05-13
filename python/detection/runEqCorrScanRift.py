import os
import multiprocessing
from multiprocessing import Manager
import time

import obspy
from obspy import read
import obspyh5

import h5py

import eqcorrscan
from eqcorrscan.core.template_gen import template_gen
from eqcorrscan.core.match_filter import Tribe
from eqcorrscan.core.match_filter import Template
from eqcorrscan.core.match_filter import match_filter

from eqCorrScanUtils import getFname
from eqCorrScanUtils import makeTemplate
from eqCorrScanUtils import parFunc
from eqCorrScanUtils import makeTemplateList

# define path to data and templates
path = "/media/Data/Data/PIG/MSEED/noIR/"
templatePath = "/home/setholinger/Documents/Projects/PIG/detections/energy/"

# read in h5 file of single channel templates- we will use the start and end times to make 3-component templates
tempH5 = obspy.read(templatePath + 'conservativeWaveforms.h5')
numTemp = len(tempH5)

# define parallel parameters
readPar = 0
nproc = 8

# define station and channel parameters
stat = ["PIG2"]
chan = "HH*"
numChan = 3
freq = [0.01,1]
#freq = [1,10]
filtType = "bandpass"

# enter the buffer used on the front and back end to produce templates
# this duration will be removed after filtering from the front and back ends of the template
buff = [2*60,2*60]
trimIdx = 260

# make and save templates (don't re run this)
#makeTemplateList(tempH5,buff,path,stat,chan,freq,filtType,readPar,nproc)

# set start date for scan
startDate = obspy.UTCDateTime(2012,6,30,0,1)
numDays = 720

# set template chunk size
blockSize = 100

# set minimum distance in seconds between detections
tolerance = 60

# set threshold for detector
threshold = 5

for i in range(numDays):

    # make variable to store detections
    detections = []

    # get UTCDateTime for current day
    currentDate = startDate + 86400*i

    try:

        # read in data to scan
        st = read()
        st.clear()
        for s in stat:
          fname = getFname(path,s,chan,currentDate)
          print("Loading " + fname + "...")
          st += obspy.read(fname)

        # basic preprocessing
        st.detrend("demean")
        st.detrend("linear")
        st.taper(max_percentage=0.01, max_length=10.)
        if filtType == "bandpass":
            st.filter(filtType,freqmin=freq[0],freqmax=freq[1])
            st.resample(freq[1]*2)
        elif filtType == "lowpass":
            st.filter(filtType,freq=freq[0])
            st.resample(freq[0]*2)
        elif filtType == "highpass":
            st.filter(filtType,freq=freq[0])

        for j in range(int(len(tempH5)/blockSize)+1):

            # start timer and give output
            timer = time.time()

    	    # get templates and template names
            templates = []
            template_names = []
            for k in range(j*blockSize,(j+1)*blockSize):
                try:
                     # read template file
                     stTemp = obspy.read('templates/' + str(freq[0]) + '-' + str(freq[1]) + 'Hz/template_'+str(k)+'.h5')

                     # occasionally templates are one sample too short- trim to the correct number of samples
                     # this handling is a bit clumsy- redo later
                     for c in range(numChan):
                        stTemp[c].data=stTemp[c].data[:trimIdx]
                     templates.append(stTemp)
                     template_names.append("tempate_" + str(k))
                     #print(stTemp)
                except:
                    pass

            # run eqcorrscan's match filter routine
            det = match_filter(template_names=template_names,template_list=templates,st=st,threshold=threshold,threshold_type="MAD",trig_int=6,cores=20)

            # append to list
            detections.extend(det)

            # stop timer and give output
            runtime = time.time() - timer

            # give some output
            if blockSize*j+1 >= numTemp:
                print("Scanned " + currentDate.date.strftime("%Y-%m-%d") + " with " + str(len(templates)) + " templates (" + str(numTemp) + "/" + str(numTemp) + ") in " + str(round(runtime,2)) + " seconds and found " + str(len(det)) + " detections")
            else:
                print("Scanned " + currentDate.date.strftime("%Y-%m-%d") + " with " + str(len(templates)) + " templates (" + str(blockSize*(j+1)) + "/" + str(numTemp) + ") in " + str(round(runtime,2)) + " seconds and found " + str(len(det)) + " detections")

        # sort detections chronologically
        detections.sort()

        # loop through all detections and eliminate redundant detections
        for d in range(len(detections)-1):
            if abs(detections[d].detect_time - detections[d+1].detect_time) < tolerance:
                detections[d] = []
        detections = list(filter(None,detections))

        print(str(len(detections)) + " detections found on " + currentDate.date.strftime("%Y-%m-%d") + " after removing duplicates")

        for detections in detections:
            detections.write('templateDetections.csv',append=True)
    except:
        print("Skipping " + currentDate.date.strftime("%Y-%m-%d"))
