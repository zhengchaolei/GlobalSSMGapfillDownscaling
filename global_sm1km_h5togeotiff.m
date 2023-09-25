clear
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A sample to read the 1-km SM data with SINUSOIDAL projection in h5 format.
% It can also merge tiled data to global covarage and save to geotiff format.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% author: Chaolei Zheng, from AIRCAS
% last edited at 2023.
% % reference:  Zheng, C., Jia L., Zhao T. 2023. A 21-year dataset
% (2000-2020) of gap-free global daily surface soil moisture at 1 km grid
% resolution. Scientific Data, 10:139. DOI:10.1038/s41597-023-01991-w.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define input and output dir
dirin = '' ;
dirout =  '';
if exist(dirout,'dir') ~= 7  %isdir
    mkdir(dirout)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define projection parameters
r = maprefcells();
r.XWorldLimits= [-20015109.354 20015109.354012];
r.YWorldLimits= [-10007554.677006 10007554.677];
r.RasterSize= [21600 43200];
r.ColumnsStartFrom='north';
r.RowsStartFrom= 'west';
% r.CellExtentInWorldX= 926.625433055833;
% r.CellExtentInWorldY= 926.625433055833;
% r.RasterInterpretation= 'cells';
% r.RasterExtentInWorldX= 40030218.708012;
% r.RasterExtentInWorldY= 20015109.354006;
% r.XIntrinsicLimits= [0.5 43200.5];
% r.YIntrinsicLimits= [0.5 21600.5];
% r.TransformationType= 'rectilinear';
% r.CoordinateSystemType= 'planar';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tags.Compression = Tiff.Compression.Deflate;
GeoKeyDirectoryTag.GTModelTypeGeoKey=1;
GeoKeyDirectoryTag.GTRasterTypeGeoKey=1;
GeoKeyDirectoryTag.GTCitationGeoKey='SINUSOIDAL No Datum. Semi-major axis: 6371007.181000, Semi-minor axis: 0.000000';
GeoKeyDirectoryTag.GeographicTypeGeoKey=32767;
GeoKeyDirectoryTag.GeogGeodeticDatumGeoKey=32767;
GeoKeyDirectoryTag.GeogLinearUnitsGeoKey=9001;
GeoKeyDirectoryTag.GeogAngularUnitsGeoKey=9102;
GeoKeyDirectoryTag.GeogSemiMajorAxisGeoKey=6.3710e+06;
GeoKeyDirectoryTag.GeogSemiMinorAxisGeoKey=6.3710e+06;
GeoKeyDirectoryTag.ProjectedCSTypeGeoKey=32767;
GeoKeyDirectoryTag.ProjCoordTransGeoKey=24;
GeoKeyDirectoryTag.ProjLinearUnitsGeoKey=9001;
GeoKeyDirectoryTag.ProjNatOriginLongGeoKey=0;
GeoKeyDirectoryTag.ProjFalseEastingGeoKey=0;
GeoKeyDirectoryTag.ProjFalseNorthingGeoKey=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read modis tile numbers
hv_all = importdata('mod_hv.mat');
lenhv=length(hv_all);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
year_n =2002; % year
lenyy = 365;  % number of days in the year
for idoy = 1 %:1:365
    
    % read and merged tiled images to global  
    data_global = zeros([18*1200,36*1200],'int16') -1 ;
    for i_hv =1:lenhv
        try
            % ihv = hv_all(i_hv,:);
            ihv = hv_all(i_hv).name;
            
            i0=find(ihv=='h');
            i00=i0(1);
            ih = str2double(ihv(i00+1:i00+2));
            iv = str2double(ihv(i00+4:i00+5));
            hv_str = ['h' num2str(ih,'%02d') 'v' num2str(iv,'%02d')];
            
            fn=[dirin    'SM.1km.Daily.'    num2str(year_n,'%04d')  num2str(lenyy,'%04d') '.'  hv_str  '.v001.h5' ];
            idata = h5read(fn,'/SM',[1 1 idoy], [1200 1200  1]);
            m_start = (iv-0) .* 1200 + 1;
            m_end = (iv-0) .* 1200 + 1200;
            n_start = (ih-0) .* 1200 + 1;
            n_end = (ih-0) .* 1200 + 1200;
            data_global(m_start:m_end,n_start:n_end) = idata;
        catch err
            disp(['error when reading: ' fn])
        end
    end
    % % data_global(mask_global<0)=-1;
    
    % save merged data to geotiff format 
    fno=[dirout 'GlobalSM1km.'   num2str(year_n,'%04d') num2str(idoy,'%03d') '.v001.tif' ];
    geotiffwrite(fno,data_global,r,'GeoKeyDirectoryTag',GeoKeyDirectoryTag,'TiffTags',tags);
end


