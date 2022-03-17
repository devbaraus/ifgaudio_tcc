rootdir = './base_pessoas_trim/';
output_dir = './base_pessoas_concat/';
folders = dir(rootdir);
folders = {folders([folders.isdir]).name};
folders = folders(~ismember(folders, {'.', '..'}));
folders = string(folders);

for aa = 1:size(folders,2)
    audio_class = folders(1,aa);
    filelist = dir(fullfile(sprintf("%s/%s",rootdir, audio_class), '*.wav'));  %get list of files and folders in any subfolder
    filelist = filelist(~[filelist.isdir]);  %remove folders from list
    folder_name = sprintf('%s\\%s', output_dir, audio_class);
    filelistPath = cell(length(filelist),1);
    audio_concat = zeros(0,1);

    for i = 1 : length(filelist)
        filelistPath{i} = strcat(filelist(i).folder, '\',filelist(i).name);
    end

    for bb = 1:size(filelistPath,1)
        filename = string(filelistPath(bb,:));
        [audioIn, fs] = audioread(filename);

%         fprintf(sprintf('%s\n',strrep(filename, '\', '/')));

        audio_concat = [audio_concat(:, 1); audioIn(:, 1)];
    end

    if ~exist(folder_name, 'dir')
       mkdir(folder_name)
    end

    audiowrite(sprintf('%s\\%s.wav', folder_name, audio_class), audio_concat, 24000)
end
