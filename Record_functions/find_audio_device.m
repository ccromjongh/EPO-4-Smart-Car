function ID = find_audio_device()

% Find correct device
devs = playrec('getDevices');
for id = 1:size(devs,2)
    if(strcmp('AudioBox ASIO Driver', devs(id).name))
        break;
    end
end
ID = devs(id).deviceID;