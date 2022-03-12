rootdir = '../base_portuguese/';
filelist = dir(fullfile(rootdir, '**\*.wav'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

filelistPath = cell(length(filelist),1);

for i = 1 : length(filelist)
    filelistPath{i} = strcat(filelist(i).folder, '\',filelist(i).name);
end

filelistPath = string(filelistPath);

for aa = 1:size(filelistPath,1)
    filename = filelistPath(aa,:);
    [audioIn, fs] = audioread(filename);
	audioIn = mean(audioIn, 2);
    audioIn = resample(audioIn, 24000,fs);
    fs = 24000;

    classe_audio = split(filelist(aa).folder,'\');
    classe_audio = string(classe_audio(5));
    audio_name = filelist(aa).name;

    idx = detectSpeech(audioIn, fs);

    if ~isempty(idx)
        first_idx = idx(1, 1);
        last_idx = idx(size(idx,1), 2);
        
        audioIn = audioIn(first_idx:last_idx,:);   
    
        folder_name = sprintf('base_portuguese_trim\\%s', classe_audio);
        
        if ~exist(folder_name, 'dir')
           mkdir(folder_name)
        end
    
        audiowrite(sprintf('%s\\%s', folder_name, audio_name), audioIn, fs)
    end
end