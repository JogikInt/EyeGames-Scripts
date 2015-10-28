function ploteye(decimated_sample, event_file, n, bad_control)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Базовая версия рисовалки траектории взгляда.
% Строит на скриншоте игры траекторию взгляда в диапазоне -100:1500 мс от
% момента конца саккады по eyeLink, рядом с которой в диапазоне -50:50 мс
% присутствует начало управляющей фиксации по eyeLines.
% Метки:
% 1) зеленый маркер - начало трека;
% 2) красный маркер - положение взгляда в момент метки начала управляющей
% фиксации eyeLines;
% 3) сиреневый маркер - положение взгляда в момент метки конца управляющей
% фиксации eyeLines.
% Принимает:
% decimated_sample, event_file - названия ASCII файла с координатами и
% соответствующего ASCII-файла событий.
% n - 400 для записей 800 мс; 600 для записей 1200 мс.
% bad_control - "true" для исключенных фиксаций в записях 1200, "false" -
% для всего остального.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% импорт данных из decimaed_samples
data = importdata(decimated_sample, ' ', 1);
eeglab_eye_data = [data.data(:, 1), data.data(:, 2)];
eeglab_eye_data = eeglab_eye_data';

% обработка в EEGlab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% импорт данных из eeglab_eye_data
EEG = pop_importdata('dataformat','array','nbchan',0,'data',eeglab_eye_data,'srate',500,'pnts',0,'xmin',0); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% импорт событий из ASCII-файла
EEG = pop_importevent( EEG, 'event',event_file,'fields',{'latency' 'type'},'skipline',1,'timeunit',1); 
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% разбиение на эпохи -0,1...1,5 с (0 - начало фиксации eyeLines)
EEG = pop_epoch( EEG, {  'fixation_start'  }, [-0.5         1.5], 'epochinfo', 'yes'); 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

% отбор эпох по условию
if bad_control == true % (отсутствие конца саккады в окрестности 50 мс от начала фиксации)
    EEG = pop_selectevent( EEG, 'latency','-50<=50','type',{'saccade_start'},'deleteevents','off','deleteepochs','on','invertepochs','on');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
else % (наличие конца саккады в окрестности 50 мс от начала фикации)
    EEG = pop_selectevent( EEG, 'latency','-50<=50','type',{'saccade_start'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
end

figure;
counter = 0;
n = size(EEG.data, 3);
for i=1:n

% отображение прогресса
    msg = sprintf('Plotting tracks: %d of %d', i, n);
    fprintf(repmat('\b',1,counter));
    cprintf('green', msg);
    counter=numel(msg);
    
    subplot(ceil(sqrt(n)), ceil(sqrt(n)), i) % рассчет количества ячеек в сабплоте
    
% загрузка изображения
    img =  imread('pepper.png'); 
    image(img) 
    
    hold on;
    plot(EEG.data(1,:,i), EEG.data(2,:,i), 'Color', [0.86, 0.86, 0.86]); % рисование линии трека
    plot(EEG.data(1,:,i), EEG.data(2,:,i), '+b'); % рисование трека плюсиками
    set(gca,'XTick',[],'YTick',[],'ButtonDownFcn',@createnew_fig); % служебное
    
    plot(EEG.data(1,1,i), EEG.data(2,1,i), '-og', 'markersize',5,'markerfacecolor','g'); % маркер начала трека
    plot(EEG.data(1,end,i), EEG.data(2,end,i), '-xr', 'markersize',5,'markerfacecolor','r'); % маркер конца трека
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!!ВНИМАНИЕ!!!
% Следующий закомментированный код остался от предыдущей версии скрипта
% для обработки 800-мс записей, где эпохи нарезались относительно конца
% саккады. Т.к. теперь все эпохи нарезаются относительно события игры,
% необходимость в поиске его времени (теперь всегда равно нулю) и
% пересчете на номер отсчета (теперь всегда 251) пропала.
% Если есть желание вернуться к варианту, где за 0 эпохи принимается конец
% саккады, нужно раскомментировать этот код и заменить "251" на "pff".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     Поиск начала фиксации в эпохе.
%     for m=1:length(EEG.epoch(1,i).eventtype) 
%         if strcmp(EEG.epoch(1,i).eventtype{m}, 'fixation_start')
%             k = m;
%             clear m
%             break
%         end
%     end
%     
%     if exist('k') == 1
%         pff = ceil((EEG.epoch(1,i).eventlatency{k}+502)/2); %перевод мс из eventlatency в номер отсчета (ms+502)/2
    plot(EEG.data(1,251,i), EEG.data(2,251,i), '-or', 'markersize',5,'markerfacecolor','r');
%         if (pff <= 800-n & pff > 0)
    plot(EEG.data(1,251+n,i), EEG.data(2,251+n,i), '-or', 'markersize',5,'markerfacecolor','m');
%         end
%         clear k pff;
%     end
    
% поиск и простановка меток концов саккад
    for m=1:length(EEG.epoch(1,i).eventtype)
        if strcmp(EEG.epoch(1,i).eventtype{m}, 'saccade_start')
            pew = ceil((EEG.epoch(1,i).eventlatency{m}+502)/2);
            plot(EEG.data(1,pew,i), EEG.data(2,pew,i), '-oy', 'markersize', 5, 'markerfacecolor','b')    
        end
    end
    axis([0,1920,0,1080]);
end
set(gca,'XTickMode', 'auto'); % служебное
fprintf(sprintf('\n'));
end

function createnew_fig(cb,eventdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Функция реализует кликабельный сабплот. Работает вместе с тем, что
% отмечено в ploteye как "служебное". Не моя, взята с просторов интернета.
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