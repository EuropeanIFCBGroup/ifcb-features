function [ ] = convert_aid2class( roi_dir_base, aid_indir, class_outdir, class2use )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%convert_aid2class('\\blackburn.whoi.edu\public\nbp1201_vpr\rois\', '\\blackburn.whoi.edu\public\nbp1201_vpr\autoid\', '\\sosiknas1\Lab_data\VPR\NBP1201\aid_class\', class2use)

if~exist(class_outdir, 'dir'),
    mkdir(class_outdir)
end;
list_titles = {'roi number'    'manual'    'auto'};
classnum_default = strmatch('unknown', class2use);
for count = 2:2, %length(class2use),
    indir = [aid_indir filesep class2use{count} filesep 'aid' filesep];
    disp(indir)
    if exist(indir, 'dir'),
        flist = dir([indir '*.h*']);
        flist = cellstr(char(flist.name));
        for fnum = 101:length(flist)
            disp(flist(fnum))
            d = importdata([indir flist{fnum}]);
            [roi_dir] = fileparts(d{1});
            %roi_dir = [roi_dir_base regexprep(roi_dir, 'c:\\data\\NBP12_01\\rois\\', '') filesep];
            ii = findstr(filesep, roi_dir);
            roi_dir = [roi_dir_base roi_dir(ii(end-2)+1:end)];
            outfile = [class_outdir 'NPB1201' regexprep(roi_dir(ii(end-3)+1:end),'\', '') '.mat'];
            d = char(d);
            ii = findstr(filesep, d(1,:));
            dnum = str2num(d(:,(ii(end)+6):end-5));
            if ~exist(outfile),
                eval(['[s,roilist] = dos(''dir ' roi_dir filesep '*.tif /B'');'])
                tt = strfind(roilist, char(10)); tt = tt(1)-1;
                roilist = regexprep(roilist, char(10), '');
                roilist = cellstr(reshape(roilist,tt,length(roilist)/tt)');
                roilist = char(sort(roilist)); 
                roilist = roilist(:,6:end-4);
                roilist = str2num(char(roilist));
                c.classlist = NaN(length(roilist),3);
                c.classlist(:,1) = roilist;
                c.classlist(:,3) = classnum_default;
                c.class2use_auto = class2use;
                c.list_titles = list_titles;
            else
                c = load(outfile);
            end;
            [~, ia, ib] = intersect(c.classlist(:,1), dnum);
            if length(ib) ~= length(dnum),
                disp('missing ROI data corresponding to aid output')
                keyboard
            end;
            c.classlist(ia,3) == count;
            save(outfile, '-struct', 'c')
        end;
    else
        disp(['missing aid output for class: ' class2use{count}])
    end;
end;

end
