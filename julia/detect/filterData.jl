using DSP
using SeisIO

function filterData(data::SeisData,filterType::String="none",freq::Array{Float64,1}=1,corners::Int=4)

    #loop through SeisChannels in SeisData object
    for c = 1:data.n
        if filterType == "Bandpass"
            #println("Bandpass filtering",data.id[1]," between ",freq[1]," and ",freq[2]," Hz")
            responsetype = Bandpass(freq[1], freq[2]; fs=data[c].fs)
            designmethod = Butterworth(corners)
            data[c].x[:] = filt(digitalfilter(responsetype, designmethod), data[c].x)
        end

        if filterType == "Lowpass"
            #println("Lowpass filtering ",data.id[1]," below ",freq[1]," Hz")
            responsetype = Lowpass(freq[1]; fs=data[c].fs)
            designmethod = Butterworth(corners)
            data[c].x[:] = filt(digitalfilter(responsetype, designmethod), data[c].x)
        end

        if filterType == "Highpass"
            #println("Highpass filtering ",data.id[1]," above ",freq[1]," Hz")
            responsetype = Highpass(freq[1]; fs=data[c].fs)
            designmethod = Butterworth(corners)
            data[c].x[:] = filt(digitalfilter(responsetype, designmethod), data[c].x)
        end
    end

    return data

end
