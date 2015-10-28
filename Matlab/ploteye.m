function ploteye(decimated_sample, event_file, n, bad_control)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������� ������ ��������� ���������� �������.
% ������ �� ��������� ���� ���������� ������� � ��������� -100:1500 �� ��
% ������� ����� ������� �� eyeLink, ����� � ������� � ��������� -50:50 ��
% ������������ ������ ����������� �������� �� eyeLines.
% �����:
% 1) ������� ������ - ������ �����;
% 2) ������� ������ - ��������� ������� � ������ ����� ������ �����������
% �������� eyeLines;
% 3) ��������� ������ - ��������� ������� � ������ ����� ����� �����������
% �������� eyeLines.
% ���������:
% decimated_sample, event_file - �������� ASCII ����� � ������������ �
% ���������������� ASCII-����� �������.
% n - 400 ��� ������� 800 ��; 600 ��� ������� 1200 ��.
% bad_control - "true" ��� ����������� �������� � ������� 1200, "false" -
% ��� ����� ����������.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ������ ������ �� decimaed_samples
data = importdata(decimated_sample, ' ', 1);
eeglab_eye_data = [data.data(:, 1), data.data(:, 2)];
eeglab_eye_data = eeglab_eye_data';

% ��������� � EEGlab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% ������ ������ �� eeglab_eye_data
EEG = pop_importdata('dataformat','array','nbchan',0,'data',eeglab_eye_data,'srate',500,'pnts',0,'xmin',0); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% ������ ������� �� ASCII-�����
EEG = pop_importevent( EEG, 'event',event_file,'fields',{'latency' 'type'},'skipline',1,'timeunit',1); 
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% ��������� �� ����� -0,1...1,5 � (0 - ������ �������� eyeLines)
EEG = pop_epoch( EEG, {  'fixation_start'  }, [-0.5         1.5], 'epochinfo', 'yes'); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% ����� ���� �� �������
if bad_control == true % (���������� ����� ������� � ����������� 50 �� �� ������ ��������)
    EEG = pop_selectevent( EEG, 'latency','-50<=50','type',{'saccade_start'},'deleteevents','off','deleteepochs','on','invertepochs','on');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
else % (������� ����� ������� � ����������� 50 �� �� ������ �������)
    EEG = pop_selectevent( EEG, 'latency','-50<=50','type',{'saccade_start'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
end

figure;
counter = 0;
n = size(EEG.data, 3);
for i=1:n

% ����������� ���������
    msg = sprintf('Plotting tracks: %d of %d', i, n);
    fprintf(repmat('\b',1,counter));
    cprintf('green', msg);
    counter=numel(msg);
    
    subplot(ceil(sqrt(n)), ceil(sqrt(n)), i) % ������� ���������� ����� � ��������
    
% �������� �����������
    img =  imread('pepper.png'); 
    image(img) 
    
    hold on;
    plot(EEG.data(1,:,i), EEG.data(2,:,i), 'Color', [0.86, 0.86, 0.86]); % ��������� ����� �����
    plot(EEG.data(1,:,i), EEG.data(2,:,i), '+b'); % ��������� ����� ���������
    set(gca,'XTick',[],'YTick',[],'ButtonDownFcn',@createnew_fig); % ���������
    
    plot(EEG.data(1,1,i), EEG.data(2,1,i), '-og', 'markersize',5,'markerfacecolor','g'); % ������ ������ �����
    plot(EEG.data(1,end,i), EEG.data(2,end,i), '-xr', 'markersize',5,'markerfacecolor','r'); % ������ ����� �����
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!!��������!!!
% ��������� ������������������ ��� ������� �� ���������� ������ �������
% ��� ��������� 800-�� �������, ��� ����� ���������� ������������ �����
% �������. �.�. ������ ��� ����� ���������� ������������ ������� ����,
% ������������� � ������ ��� ������� (������ ������ ����� ����) �
% ��������� �� ����� ������� (������ ������ 251) �������.
% ���� ���� ������� ��������� � ��������, ��� �� 0 ����� ����������� �����
% �������, ����� ����������������� ���� ��� � �������� "251" �� "pff".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     ����� ������ �������� � �����.
%     for m=1:length(EEG.epoch(1,i).eventtype) 
%         if strcmp(EEG.epoch(1,i).eventtype{m}, 'fixation_start')
%             k = m;
%             clear m
%             break
%         end
%     end
%     
%     if exist('k') == 1
%         pff = ceil((EEG.epoch(1,i).eventlatency{k}+502)/2); %������� �� �� eventlatency � ����� ������� (ms+502)/2
    plot(EEG.data(1,251,i), EEG.data(2,251,i), '-or', 'markersize',5,'markerfacecolor','r');
%         if (pff <= 800-n & pff > 0)
    plot(EEG.data(1,251+n,i), EEG.data(2,251+n,i), '-or', 'markersize',5,'markerfacecolor','m');
%         end
%         clear k pff;
%     end
    
% ����� � ����������� ����� ������ ������
    for m=1:length(EEG.epoch(1,i).eventtype)
        if strcmp(EEG.epoch(1,i).eventtype{m}, 'saccade_start')
            pew = ceil((EEG.epoch(1,i).eventlatency{m}+502)/2);
            plot(EEG.data(1,pew,i), EEG.data(2,pew,i), '-oy', 'markersize', 5, 'markerfacecolor','b')    
        end
    end
    axis([0,1920,0,1080]);
end
set(gca,'XTickMode', 'auto'); % ���������
fprintf(sprintf('\n'));
end

function createnew_fig(cb,eventdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������� ��������� ������������ �������. �������� ������ � ���, ���
% �������� � ploteye ��� "���������". �� ���, ����� � ��������� ���������.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cb is the handle of the axes that was clicked
% click on the whitespace within and axes and not on the line object
% copy the axes object to the new figure
f = figure;
img =  imread('pepper.png');
image(img)
hh = copyobj(cb,f);
% for the new figure assign the ButtonDownFcn to empty
set(hh,'ButtonDownFcn',[]);
% resize the axis to fill the figure
set(hh, 'Position', get(0, 'DefaultAxesPosition'));

end