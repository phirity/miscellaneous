
raw = spm_vol('spm_raw.nii');
denoised = spm_vol('spm_conn.nii');
raw_vols=spm_read_vols(raw);
conn_vols=spm_read_vols(denoised);
corrs = zeros(size(raw_vols,1),size(raw_vols,2),size(raw_vols,3));
pvals = zeros(size(raw_vols,1),size(raw_vols,2),size(raw_vols,3));
for i = 1:size(raw_vols,1)
    for j = 1:size(raw_vols,2)
        for k = 1:size(raw_vols,3)
            X=reshape(conn_vols(i,j,k,:),84,1);
            Y=reshape(raw_vols(i,j,k,:),84,1);
            [R,P] = corrcoef(X,Y);
            corrs(i,j,k) = R(1,2);
            pvals(i,j,k) = P(1,2);
        end
    end
end




niftiwrite(corrs,'outputcorr.nii')
niftiwrite(pvals,'outputpval_raw.nii')
pvals_significant = double(pvals < 0.001);
niftiwrite(pvals,'outputpval_sig.nii')

    
% Below is about plotting time-series. You may need to multiply some numbers to compare different time series in different scales. 
% You can just use FSLview or other display software to draw time-series plot.
    

coordinates = {...
         [45 27 29 1]; ... % frontal GM coord
         [ 16 42 29 1]; ... % WM coord
         [ 31 25 29 1]      % CSF coord   
               };

for c = 1:length(coordinates)             
    if size(coordinates{c},1) > 1
        coordinates2=coordinates(1,:)';
    else
        coordinates2=coordinates{c}'; 
    end


timeseries_raw = squeeze(conn_vols(coordinates2(1),coordinates2(2),coordinates2(3),:)); % time course of image 1
timeseries_conn = squeeze(raw_vols(coordinates2(1),coordinates2(2),coordinates2(3),:)); % time course of image 2

name = num2str(coordinates{c}(1:3));
figure
%ylim manual
%ylim([min([min(timeseries_raw),min(timeseries_conn)])  max([max(timeseries_raw),max(timeseries_conn)])]) %set the y limits to be comparable

subplot(2,1,1); plot(timeseries_raw*100); title('spmraw timeseries'); ylim manual; ylim([min(timeseries_raw*100)-100 max(timeseries_raw*100)+100]); ylabel([name])
subplot(2,1,2); plot(timeseries_conn,'r'); title('spmconn timeseries'); ylim manual; ylim([min(timeseries_conn)-100 max(timeseries_conn)+100]); xlabel('TIME')
%H=ylim(subplot(2,1,1));
%ylim(subplot(2,1,2),H);
end
