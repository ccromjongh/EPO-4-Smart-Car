function findPorts (hObject, ~)
    [~, serialPorts] = dos(['REg QUERY ' 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM']);
    ports = unique(regexp(serialPorts, 'COM[0-9]+', 'match'));
end